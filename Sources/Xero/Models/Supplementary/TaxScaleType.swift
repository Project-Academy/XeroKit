//
//  TaxScaleType.swift
//  XeroKit
//
//  Introduced under STP Phase 2 reporting. See ATO documentation for
//  the precise semantics of each value.
//

import Foundation

public enum TaxScaleType: String, Codable {
    case regular                  = "REGULAR"
    case actorsArtistsEntertainers = "ACTORSARTISTSENTERTAINERS"
    case horticulturistOrShearer  = "HORTICULTURISTORSHEARER"
    case seniorOrPensioner        = "SENIORORPENSIONER"
    case workingHolidayMaker      = "WORKINGHOLIDAYMAKER"
    /// Only valid when `ResidencyStatus` is `.foreignResident`.
    case foreign                  = "FOREIGN"
}
