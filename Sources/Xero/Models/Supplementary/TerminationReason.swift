//
//  TerminationReason.swift
//  XeroKit
//

import Foundation

public enum TerminationReason: String, Codable {
    /// Voluntary cessation — resignation, retirement, abandonment.
    case V
    /// Ill health — resignation due to medical condition or permanent disability.
    case I
    /// Deceased.
    case D
    /// Redundancy — employer-initiated genuine redundancy or early-retirement scheme.
    case R
    /// Dismissal — employer-initiated termination for misconduct or inability to perform.
    case F
    /// Contract cessation — natural end of a limited engagement, seasonal work, or casual cease.
    case C
    /// Transfer — administrative move across payroll systems, outsourcing, etc.
    case T
}
