//
//  SuperLine.swift
//  XeroKit
//
//  Individual superannuation contribution line attached to a Payslip
//  or PayTemplate. Combined under `PayTemplate.superLines`.
//

import Foundation

public typealias SuperLines = [SuperLine]

public struct SuperLine: Codable {
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
    public enum ContributionType: String, Codable {
        /// Mandatory employer contribution.
        case SGC
        /// Pre-tax reportable employer super contribution (RESC on payment summaries).
        case SALARYSACRIFICE
        /// Additional employer super contribution (RESC on payment summaries).
        case EMPLOYERADDITIONAL
        /// Post-tax employee super contribution.
        case EMPLOYEE
    }

    public enum CalculationType: String, Codable {
        /// Fixed-rate contribution (only valid for voluntary super).
        case FIXEDAMOUNT
        /// Percentage of earnings.
        case PERCENTAGEOFEARNINGS
        /// SGC statutory rate.
        case STATUTORY
    }
}

