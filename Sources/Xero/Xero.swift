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

        print("Status Code: \(statusCode)")

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
            guard let retryAfter = response.header("retry-after"),
                  let seconds = Int(retryAfter)
            else { throw HTTPError.rateLimited(retryAfter: 0) }
            return try await retry(request, after: .seconds(seconds), onExhausted: HTTPError.rateLimited(retryAfter: seconds))
        case 500:
            return try await retry(request, after: .seconds(3), onExhausted: HTTPError.otherError(statusCode: 500))
        default:
            break
        }

        return response
    }

    /**
     Re-fires `request` after `delay`, decrementing its retry budget.
     If the budget is exhausted (`.noRetry` or `.retryWithLimit(<=0)`)
     the supplied `onExhausted` error is thrown instead.
     */
    private static func retry(_ request: R, after delay: Duration, onExhausted: HTTPError) async throws -> Response {
        switch request.retryPolicy {
        case .noRetry, .retryWithLimit(maxAttempts: ...0):
            print("Retry budget exhausted: \(onExhausted)")
            throw onExhausted
        case .retryWithLimit(maxAttempts: let n):
            print("Retrying in \(delay) (attempts left: \(n - 1))")
            var next = request
            next.retryPolicy = .retryWithLimit(maxAttempts: n - 1)
            try await Task.sleep(for: delay)
            return try await self.response(for: next)
        case .retry:
            print("Retrying in \(delay)")
            try await Task.sleep(for: delay)
            return try await self.response(for: request)
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
