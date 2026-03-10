//
//  RetryPolicy.swift
//  XeroKit
//
//  Created by Mrinaank Sinha on 10/3/2026.
//

public enum RetryPolicy: Sendable {
    case retry
    case retryWithLimit(maxAttempts: Int)
    case noRetry
}
