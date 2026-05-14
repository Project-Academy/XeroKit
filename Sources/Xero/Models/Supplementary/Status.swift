//
//  Status.swift
//  XeroKit
//
//  Employee status — ACTIVE or TERMINATED. Reflects whether a
//  `TerminationDate` has been set on the Employee.
//

import Foundation

public enum Status: String, Codable {
    /// Employee with no Termination Date.
    case ACTIVE
    /// Employee with a Termination Date.
    case TERMINATED
}
