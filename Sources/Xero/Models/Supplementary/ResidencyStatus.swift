//
//  ResidencyStatus.swift
//  XeroKit
//

import Foundation

public enum ResidencyStatus: String, Codable {
    /// Employee is an Australian resident for tax purposes.
    /// `AustralianResidentForTaxPurposes` must be `true`.
    case AUSTRALIANRESIDENT
    /// Employee is a foreign resident for tax purposes.
    /// `AustralianResidentForTaxPurposes` must be `false`.
    /// `TaxScaleType` must be one of `HORTICULTURISTORSHEARER` or `FOREIGN`.
    case FOREIGNRESIDENT
}
