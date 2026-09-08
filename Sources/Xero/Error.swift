//
//  Error.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation

public protocol XeroError: Error {}

public enum AuthError: Error, XeroError {
    case failedToFetchToken
}

public enum EmployeesError: Error, XeroError {
    case noEmployeesFound
    case multipleEmployeesFound
    case missingEmployeeID
}

public enum FetchError: Error, XeroError {
    case noItemsFound
    case multipleItemsFound
}

public enum EarningsRatesError: Error, XeroError {
    case noEarningsLines
}

public enum HTTPError: Error, XeroError {
    case rateLimited(retryAfter: Int)
    case otherError(statusCode: Int)
    /**
     A request Xero rejected, carrying whatever reason it gave.

     Previously a rejected request was returned to the caller like any
     other response, and the failure surfaced when the envelope
     decoder hit a body that had no `Status` key — so the error read
     "Key 'Status' not found" and Xero's actual message was discarded.
     */
    case requestFailed(statusCode: Int, message: String?)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rateLimited(let seconds):
            "Xero rate limit reached; retry after \(seconds)s."
        case .otherError(let statusCode):
            "Xero returned HTTP \(statusCode)."
        case .requestFailed(let statusCode, let message):
            if let message { "Xero returned HTTP \(statusCode): \(message)" }
            else           { "Xero returned HTTP \(statusCode)." }
        }
    }
}
