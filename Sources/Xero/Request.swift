//
//  Request.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation

public struct Request: APIRequest {
    public typealias API = Xero
    
    //--------------------------------------
    // MARK: - VARIABLES -
    //--------------------------------------
    public var urlRequest: URLRequest
    public var httpMethod: HTTPMethod
    public let baseURL: URL
    
    //--------------------------------------
    // MARK: - INTERNAL STATE -
    //--------------------------------------
    public var headers: [String: String] = [:]
    public var accepts: ContentType = .JSON
    public var content: ContentType = .JSON
    
    public var retryPolicy: RetryPolicy = .retry
    public var params: [String: (any Sendable)] = [:]
    public var paramTransformer: (@Sendable ([String: Any]) throws -> Data) = { params in
        try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
    
    //--------------------------------------
    // MARK: - INITIALISERS -
    //--------------------------------------
    public init(url: URL, _ method: HTTPMethod? = nil) {
        baseURL = url
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = (method ?? .GET).rawValue
        httpMethod = method ?? .GET
    }
    
    //--------------------------------------
    // MARK: - MODIFIERS -
    //--------------------------------------
    public func `where`(_ condition: String) -> Self {
        params(["where": condition
            .replacingOccurrences(of: "'", with: "\"")])
    }
    public func `where`(_ conditions: [String]) -> Self {
        params(["where": conditions
            .joined(separator: "&&")
            .replacingOccurrences(of: "'", with: "\"")])
    }
    public func order(_ property: String, _ direction: SortDirection) -> Self {
        params(["order": "\(property) \(direction.rawValue)"])
    }
    public func page(_ page: Int) -> Self {
        params(["page": page])
    }
    public func pageSize(_ count: Int, parameterName name: String = "pageSize") -> Self {
        var toAdd: [String: (any Sendable)] = [name: count]
        if params["page"] == nil {
            toAdd["page"] = 1
        }
        return params(toAdd)
    }
    public func retryPolicy(_ policy: RetryPolicy) -> Self {
        var request = self
        request.retryPolicy = policy
        return request
    }

    /**
     Replace the param-to-body transformer with a custom closure.
     Used for Xero's array-wrapped POST bodies (Employees / Payslip /
     SuperFunds) — Xero wants `[{...}]` even when posting a single
     entity, so the transformer wraps the params dict in an array
     before serialising:

     ```swift
     .params(employee.json)
     .paramTransformer { dict in
         try JSONSerialization.data(withJSONObject: [dict], options: .prettyPrinted)
     }
     ```
     */
    public func paramTransformer(_ transform: @escaping (@Sendable ([String: Any]) throws -> Data)) -> Self {
        var request = self
        request.paramTransformer = transform
        return request
    }
}

public enum SortDirection: String {
    case ascending = "ASC"
    case descending = "DESC"
}

