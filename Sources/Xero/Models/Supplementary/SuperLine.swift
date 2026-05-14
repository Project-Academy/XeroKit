//
//  SuperLine.swift
//  XeroKit
//
//  Individual superannuation contribution line attached to a Payslip
//  or PayTemplate. Combined under `PayTemplate.superLines`.
//

import Foundation

public typealias SuperLines = [SuperLine]

public struct SuperLine: Codable, Sendable {
    /// The `SuperMembership` this line contributes to.
    public var superMembershipId:   String?
    public var contributionType:    ContributionType?
    public var calculationType:     CalculationType?
    /// Account code for the Expense Account.
    public var expenseAccountCode:  String?
    /// Account code for the Liability Account.
    public var liabilityAccountCode:String?
    /// Percentage of earnings (only meaningful when `calculationType` is `.PERCENTAGEOFEARNINGS`).
    public var percentage:          Double?

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        superMembershipId:    String? = nil,
        contributionType:     ContributionType? = nil,
        calculationType:      CalculationType? = nil,
        expenseAccountCode:   String? = nil,
        liabilityAccountCode: String? = nil,
        percentage:           Double? = nil
    ) {
        self.superMembershipId    = superMembershipId
        self.contributionType     = contributionType
        self.calculationType      = calculationType
        self.expenseAccountCode   = expenseAccountCode
        self.liabilityAccountCode = liabilityAccountCode
        self.percentage           = percentage
    }

    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case superMembershipId    = "SuperMembershipID"
        case contributionType     = "ContributionType"
        case calculationType      = "CalculationType"
        case expenseAccountCode   = "ExpenseAccountCode"
        case liabilityAccountCode = "LiabilityAccountCode"
        case percentage           = "Percentage"
    }

    //--------------------------------------
    // MARK: - ENUMS -
    //--------------------------------------
    public enum ContributionType: String, Codable, Sendable {
        /// Mandatory employer contribution.
        case sgc                = "SGC"
        /// Pre-tax reportable employer super contribution (RESC on payment summaries).
        case salarySacrifice    = "SALARYSACRIFICE"
        /// Additional employer super contribution (RESC on payment summaries).
        case employerAdditional = "EMPLOYERADDITIONAL"
        /// Post-tax employee super contribution.
        case employee           = "EMPLOYEE"
    }

    public enum CalculationType: String, Codable, Sendable {
        /// Fixed-rate contribution (only valid for voluntary super).
        case fixedAmount         = "FIXEDAMOUNT"
        /// Percentage of earnings.
        case percentageOfEarnings = "PERCENTAGEOFEARNINGS"
        /// SGC statutory rate.
        case statutory           = "STATUTORY"
    }
}

