//
//  ResidencyStatus.swift
//  XeroKit
//

import Foundation

public enum ResidencyStatus: String, Codable {
    /// Employee is an Australian resident for tax purposes.
    /// `australianResidentForTaxPurposes` must be `true`.
    case australianResident = "AUSTRALIANRESIDENT"
    /// Employee is a foreign resident for tax purposes.
    /// `australianResidentForTaxPurposes` must be `false`.
    /// `taxScaleType` must be one of `.horticulturistOrShearer` or `.foreign`.
    case foreignResident    = "FOREIGNRESIDENT"
}
