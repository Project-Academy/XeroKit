//
//  ExemptionTypes.swift
//  XeroAPI
//
//  Created by Sarfraz Basha on 18/11/2025.
//

import Foundation

public enum TFNExemptionType: String, Codable {
    /// Employee has not provided a TFN.
    /// TaxScaleType must not be set.
    case notQuoted = "NOTQUOTED"
    /// Employee has made a separate application or Enquiry to the ATO for a new or existing TFN.
    case pending = "PENDING"
    /// Employee is claiming that they are in receipt of a pension, benefit or allowance.
    /// Employees with an Income Type of ‘Working Holiday Maker’ cannot have a TFN exemption of PENSIONER.
    case pensioner = "PENSIONER"
    /// Employee is claiming an exemption as they are under the age of 18 and do not earn enough to pay tax.
    /// Employees with an Income Type of ‘Working Holiday Maker’ cannot have a TFN exemption of UNDER18.
    case under18 = "UNDER18"
}
