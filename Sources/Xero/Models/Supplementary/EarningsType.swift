//
//  EarningsType.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

public enum EarningsType: String, Codable {
    case ordinary = "OrdinaryTimeEarnings"
    case overtime = "OvertimeEarnings"
    /// EarningsRates with EarningsType ALLOWANCE also require an ALLOWANCETYPE value.
    case allowance = "Allowance"
    /// Earnings Rate with LumpSumA Type is a systems generated earnings rate and can only be used in final pays.
    /// It is used for payments of ATO mandated Lump sum A.
    case lumpSumA = "LumpSumA"
    /// Earnings Rate with LumpSumB Type is a systems generated earnings rate and can only be used in final pays.
    /// It is used for payments of ATO mandated Lump sum B.
    case lumpSumB = "LumpSumB"
    /// Earnings Rate with LumpSumD Type is a systems generated earnings rate and can only be used in final pays.
    /// It is used for payments of ATO mandated Lump sum D.
    case lumpSumD = "LumpSumD"
    /// EarningsRate with LumpSumE Type is used for payments of ATO mandated Lump sum E.
    case lumpSumE = "LumpSumE"
    /// EarningsRates with EarningsType EMPLOYMENTTERMINATIONPAYMENT can only be used in final pays.
    case terminationPayment = "EmploymentTerminationPayment"
    /// EarningsRates with EarningsType BONUSESANDCOMMISSIONS always subject to tax and reportable as W1
    case bonuses = "BonusesAndCommissions"
    /// Earnings Rates with LUMPSUMW Type is used for payments made for return to work amounts given to employees.
    /// It is always subject to tax and reportable as W1.
    case lumpSumW = "LumpSumW"
    /// Earnings Rates with DIRECTORSFEES Type is used for payments to director of a company or a person performing duties of a director.
    /// It is always subject to tax and reportable as W1.
    case directorsFees = "DirectorsFees"
    /// Earnings Rates with PAIDPARENTALLEAVE Type is used for payments to eligible employees when they are on parental leave.
    /// It is always subject to tax and reportable as W1.
    case paidParentalLeave = "PaidParentalLeave"
    /// Earnings Rates with WORKERSCOMPENSATION Type is used for wage replacement and medical benefits to employees injured in the course of employment.
    /// It is always subject to tax and reportable as W1.
    case workersComp = "WorkersCompensation"
}
