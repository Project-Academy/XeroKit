//
//  EarningsRate.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation


public struct EarningsRate_Template: Codable {
    
    //--------------------------------------
    // MARK: - VARIABLES -
    //--------------------------------------
    /// Unique Xero identifier of the earnings rate
    public let rateId: String
    /// Name of the earnings rate (max length = 100)
    public let name: String
    
    public let earningsType: EarningsType
    
    public let rateType: RateType
    /// Type of units used to record earnings (max length = 50).
    /// Only When RateType is RATEPERUNIT
    public var typeOfUnits: String?
    /// Default rate per unit (optional).
    /// Only applicable if RateType is RATEPERUNIT.
    public var ratePerUnit: Double?
    
    /// Indicates whether an earning type is active
    public let isActive: Bool
    /// The account that will be used for the earnings rate
    public let expenseAccountID: String?

    /**
     This is the multiplier used to calculate the rate per unit, based on the employee’s ordinary earnings rate.
     For example, for time and a half enter 1.5.
     Only applicable if RateType is .multiple
     */
    public let multiplier: Double?
    /// Optional Fixed Rate Amount. Applicable only if RateType is FixedAmount
    public let fixedAmount: Double?
    /// How the earnings should be treated for termination payments
    public let etpType: ETPType?
    
    /// Payments of this type are subject to PAYG withholding
    public let isSubjectToTax: Bool?
    /**
     Payments of this type are subject to Superannuation Guarantee Contribution
     See the [ATO website](https://www.ato.gov.au/business/super-for-employers) for details of which payments are exempt from SGC
     */
    public let isSubjectToSuper: Bool?
    /// Whether the earnings rate is reportable or exempt from W1
    public let isReportableAsW1: Bool?
    
    /// Indicates that this earnings rate should accrue leave.
    /// Only applicable if RateType is MULTIPLE
    public let accrueLeave: Bool?
    /// For allowances only, determines the type of allowance
    public let allowanceType: AllowanceType?
    /// For allowances only, determines the category of allowance
    public let allowanceCategory: AllowanceCategory?
    /// For allowances using RatePerUnit only, whether it contributes towards the overtime rate
    public let affectsOvertimeRate: Bool?
    /// For allowances using RatePerUnit only, whether it contributes towards the annual leave rate
    public let affectsAnnualLeave: Bool?
    
    
    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case rateId = "earningsRateID"
        case name
        case earningsType
        case rateType
        case typeOfUnits
        case ratePerUnit
        case isActive = "currentRecord"
        case expenseAccountID
        case multiplier = "MultipleOfOrdinaryEarningsRate"
        case fixedAmount
        case etpType
        case isSubjectToTax
        case isSubjectToSuper
        case isReportableAsW1
        case accrueLeave
        case allowanceType
        case allowanceCategory
        case affectsOvertimeRate = "allowanceContributesToOvertimeRate"
        case affectsAnnualLeave = "allowanceContributesToAnnualLeaveRate"
    }
    
}
extension EarningsRate_Template: CustomStringConvertible {
    public var description: String {
        var desc = "(\(name)"
        if earningsType != .ordinary { desc += ", earningsType: \(earningsType)" }
        if rateType != .ratePerUnit { desc += ", rateType: \(rateType)" }
        else {
            if let ratePerUnit {
                desc += ", defaultRate: \(ratePerUnit.formatted(.currency(code: "AUD")))"
                if let typeOfUnits {
                    var units = typeOfUnits
                    units.removeLast()
                    desc += " per \(units)" }
            }
        }
        if isActive == false { desc += ", isActive: false" }
        desc += ", ID: \(rateId))"
        return desc
    }
}


extension EarningsRate_Template {
    
    public var rate: PayRate {
        let rate = PayRate(rawValue: name)
        if let rate { return rate }
        return switch name {
        case "English Tutes": .EnglishTutes
        case "Marking PPF": .MarkingPPF
        case "Heads": .Head
        case "Wilf Filming": .WilfFilming
        default: .Other
        }
    }
    
    public var basis: EarningsBasis {
        guard let typeOfUnits
        else {
            return switch rate {
            case .Other: .other
            case .ThinkTank: .perUnit("ThinkTank")
            default: .perHour
            }
        }
        return switch typeOfUnits {
        case "Hours": .perHour
        default: .perUnit(typeOfUnits)
        }
        
    }
}
public enum PayRate: String, Codable, Sendable, CustomStringConvertible {
    case Teaching
    case Tutoring
    case ThinkTank
    case EnglishTutes
    
    case Resourcing
    
    case Marking
    case MarkingPPF
    
    case Operations
    case Marketing
    case Design
    case Coding
    case Shadowing
    case Head
    
    case WilfFilming
    case Other
    
    public var description: String { ".\(rawValue)" }
}
