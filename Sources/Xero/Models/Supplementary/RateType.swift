//
//  RateType.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

public enum RateType: String, Codable {
    case fixed = "FixedAmount"
    /// Multiple of Employee’s Ordinary Earnings Rate: an earnings rate which is derived from an employee’s ordinary earnings rate
    case multiple = "MultipleOfOrdinaryEarningsRate"
    /// An earnings rate allowing entry of a rate per unit
    case ratePerUnit = "RatePerUnit"
}
