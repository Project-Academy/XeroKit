//
//  Xero.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation
@_exported import Tapioca
import Expires

@MainActor
public struct Xero: Tapioca {
    public typealias R = Request

    public static var baseURL: URL = URL(string: "https://api.xero.com/payroll.xro")!

    //--------------------------------------
    // MARK: - AUTH TOKEN -
    //--------------------------------------
    @Expires(in: .seconds(1800))
    internal static var token: Bearer? = {
        Task { try await updateToken() }
        return nil
    }()
    public static var hasToken: Bool { _token.isValid }
    public static var tokenFetcher: (() async throws -> (Bearer))?

    /**
     Single in-flight task that coalesces concurrent callers onto one
     `tokenFetcher` invocation — without this, every parallel request
     that hits the expired-token branch would fire its own refresh.
     */
    internal static var tokenTask: Task<Bearer, Error>?

    internal static func updateToken() async throws -> Bearer {
        if let existing = tokenTask { return try await existing.value }
        let task = Task<Bearer, Error> {
            defer { tokenTask = nil }
            guard let bearer = try await tokenFetcher?()
            else { throw AuthError.failedToFetchToken }
            _token.update(bearer, expiresIn: .seconds(bearer.expiresIn))
            print("Token Updated:", _token)
            return bearer
        }
        tokenTask = task
        return try await task.value
    }

    //--------------------------------------
    // MARK: - PRE- & POST-PROCESS -
    //--------------------------------------
    @MainActor
    public static func preProcess(request: R) async throws -> R {

        // MARK: Auth
        let _token: Bearer
        if let token { _token = token }
        else { _token = try await updateToken() }

        // MARK: Prep
        let updated = request
            .content(type: request.content)
            .accepts(type: request.accepts)
            .setHeader(key: "Authorization", value: _token.key)

        return updated
    }

    public static func postProcess(response: Response, from request: R) async throws -> Response {

        // MARK: Error Handling
        guard let statusCode = response.statusCode
        else { throw PrestoError.noStatusCode }

        guard statusCode != 200
        else { return response }

        // Differentiate retryable rate-limit responses from generic
        // failures up front so the console doesn't bury a 429 (which
        // the caller will recover from automatically) inside the same
        // log line as a fatal error.
        if statusCode == 429 {
            print("Xero rate-limited (HTTP 429) on \(request.urlRequest.url?.absoluteString ?? "?")")
        } else {
            print("Xero Status Code: \(statusCode)")
            // Xero puts the actual reason in the body, and neither
            // envelope can decode an error response — `Status` /
            // `httpStatusCode` are required keys — so the caller sees
            // "Key 'Status' not found" instead of the API's message.
            // Without this line that message is simply lost.
            if let body = String(data: response.data, encoding: .utf8),
               !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("Xero response body: \(body.prefix(2000))")
            }
        }

        switch statusCode {
        case 401: // Unauthorized / AuthenticationUnsuccessful
            print("Error: 401 Unauthorized")

            /**
             NOTE: Take care with fetching a token to avoid scenarios
             where an infinite loop could occur.

             e.g. if ``tokenFetcher`` is broken in a way that always returns an invalid token,
             then the request will hit ``postProcess`` with a 401, refetch another invalid token,
             and re-fire indefinitely.
             */
            /*
            print("401 Unauthorized, refreshing token.")
            if let bearer = try await tokenFetcher?() {
                updateToken(with: bearer)
                // Re-fire the request
                return try await self.response(for: request)
            }
             */

            throw URLError(.userAuthenticationRequired)
        case 429:
            if let remaining = response.header("x-daylimit-remaining") {
                print("Remaining calls for today: \(remaining)")
            }
            // Some Xero rate-limit responses (esp. concurrent-limit
            // breaches at the edge) come back without a usable
            // `Retry-After` — missing, fractional, or HTTP-date
            // formatted. We already know it's a 429 and we want to
            // back off; fall back to a default delay rather than
            // killing the entire batch.
            let seconds = parseRetryAfter(response.header("retry-after")) ?? 30
            return try await retry(request, after: .seconds(seconds), onExhausted: HTTPError.rateLimited(retryAfter: seconds))
        case 500:
            return try await retry(request, after: .seconds(3), onExhausted: HTTPError.otherError(statusCode: 500))
        default:
            break
        }

        return response
    }

    /**
     Parses a `Retry-After` header into integer seconds. Accepts the
     two RFC-7231 forms (delta-seconds + HTTP-date) plus fractional
     seconds, which some edges return. Returns nil if the value is
     missing or unrecognisable; callers should pick a sane fallback
     rather than abandon the retry.
     */
    private static func parseRetryAfter(_ value: String?) -> Int? {
        guard let value, !value.isEmpty else { return nil }
        if let s = Int(value) { return max(s, 0) }
        if let d = Double(value) { return max(Int(d.rounded(.up)), 0) }
        if let date = httpDateFormatter.date(from: value) {
            return max(Int(date.timeIntervalSinceNow.rounded(.up)), 0)
        }
        return nil
    }

    private static let httpDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "GMT")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return f
    }()

    /**
     Re-fires `request` after `delay`, decrementing its retry budget.
     If the budget is exhausted (`.noRetry` or `.retryWithLimit(<=0)`)
     the supplied `onExhausted` error is thrown instead.
     */
    private static func retry(_ request: R, after delay: Duration, onExhausted: HTTPError) async throws -> Response {
        let url = request.urlRequest.url?.absoluteString ?? "?"
        switch request.retryPolicy {
        case .noRetry, .retryWithLimit(maxAttempts: ...0):
            print("⚠️ Xero retry budget exhausted (\(onExhausted)) on \(url)")
            throw onExhausted
        case .retryWithLimit(maxAttempts: let n):
            print("⏳ Xero retry in \(delay) (attempts left: \(n - 1)) — \(url)")
            var next = request
            next.retryPolicy = .retryWithLimit(maxAttempts: n - 1)
            try await Task.sleep(for: delay)
            let response = try await self.response(for: next)
            print("✅ Xero retry succeeded (\(response.statusCode ?? 0)) — \(url)")
            return response
        case .retry:
            print("⏳ Xero retry in \(delay) — \(url)")
            try await Task.sleep(for: delay)
            let response = try await self.response(for: request)
            print("✅ Xero retry succeeded (\(response.statusCode ?? 0)) — \(url)")
            return response
        }
    }
}

public struct Bearer: Codable, Sendable {
    let token:      String
    let expiresIn:  Int
    let tokenType:  String
    let scopes:     [String]

    public var key: String { "Bearer \(token)" }
}
extension Bearer: CustomStringConvertible {
    public var description: String {
        "Bearer(token: \(token.prefix(8))...\(token.suffix(8)))"
    }
}

internal enum API {}
