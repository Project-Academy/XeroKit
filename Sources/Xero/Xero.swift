//
//  Xero.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation
@_exported import Tapioca

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
    internal static var tokenTask: Task<Bearer, Error>?
    internal static func updateToken() async throws -> Bearer {
        
        guard tokenTask == nil
        else { return try await tokenTask!.value }
        tokenTask = Task {
            defer { tokenTask = nil }
            
            guard let bearer = try await tokenFetcher?()
            else { throw AuthError.failedToFetchToken }
            _token.update(bearer, expiresIn: .seconds(bearer.expiresIn))
            print("Token Updated:", _token)
            return bearer
        }
        return try await tokenTask!.value

    }
    public static var tokenFetcher: (() async throws -> (Bearer))?
    
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
            if let remaining = response.headers?["x-daylimit-remaining"] as? String {
                print("Remaining calls for today: \(remaining)")
            }
            if let retryAfter = response.headers?["retry-after"] as? String,
               let seconds = Int(retryAfter) {
                print("Rate limit hit, trying again in \(retryAfter) seconds.")
                try await Task.sleep(for: .seconds(seconds))
                return try await self.response(for: request)
            }
        case 500:
            print("Error 500, retrying in 3 seconds.")
            try await Task.sleep(for: .seconds(3))
            return try await self.response(for: request)
        default:
            break
        }
        
        return response
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

internal struct API {}
