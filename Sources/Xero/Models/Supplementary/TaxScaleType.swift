//
//  TaxScaleType.swift
//  XeroKit
//
//  Introduced under STP Phase 2 reporting. See ATO documentation for
//  the precise semantics of each value.
//

import Foundation

public enum TaxScaleType: String, Codable {
    case REGULAR
    case ACTORSARTISTSENTERTAINERS
    case HORTICULTURISTORSHEARER
    case SENIORORPENSIONER
    case WORKINGHOLIDAYMAKER
    /// Only valid when `ResidencyStatus` is `FOREIGNRESIDENT`.
    case FOREIGN
}
