//
//  Error.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

public protocol XeroError: Error {}

public enum AuthError: Error, XeroError {
    case failedToFetchToken
}

public enum EmployeesError: Error, XeroError {
    case noEmployeesFound
    case multipleEmployeesFound
}

public enum FetchError: Error, XeroError {
    case noItemsFound
    case multipleItemsFound
}
