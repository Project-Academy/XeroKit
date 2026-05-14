//
//  TaxDeclaration.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 18/11/2025.
//

import Foundation

public struct TaxDeclaration: Codable {

    //--------------------------------------
    // MARK: - CORE FIELDS -
    //--------------------------------------
    /// Employee's TFN. May be `nil` when a `TFNExemptionType` is set
    /// (e.g. PENDING) — the employee can be onboarded before quoting
    /// their TFN.
    public var taxFileNumber: String?
    public var thresholdClaimed: Bool
    public var hasLoansOrDebt: Bool

    public var employeeId: String?
    public var employmentBasis: EmploymentBasis
    /// Optional — only set when the employee hasn't quoted a TFN.
    /// Mutually exclusive with `taxFileNumber` in practice.
    public var exemptionType: TFNExemptionType?

    //--------------------------------------
    // MARK: - STP 2 / RESIDENCY -
    //--------------------------------------
    /// STP Phase 2 field. See `TaxScaleType` for valid values.
    public var taxScaleType: TaxScaleType?
    public var residencyStatus: ResidencyStatus?
    /// Must be `true` if `residencyStatus` is `.AUSTRALIANRESIDENT`,
    /// `false` if `.FOREIGNRESIDENT`.
    public var australianResidentForTaxPurposes: Bool?

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        thresholdClaimed: Bool,
        hasLoansOrDebt: Bool,
        employmentBasis: EmploymentBasis,
        exemptionType: TFNExemptionType? = nil,
        taxFileNumber: String? = nil,
        employeeId: String? = nil,
        taxScaleType: TaxScaleType? = nil,
        residencyStatus: ResidencyStatus? = nil,
        australianResidentForTaxPurposes: Bool? = nil
    ) {
        self.thresholdClaimed = thresholdClaimed
        self.hasLoansOrDebt = hasLoansOrDebt
        self.employmentBasis = employmentBasis
        self.exemptionType = exemptionType
        self.taxFileNumber = taxFileNumber
        self.employeeId = employeeId
        self.taxScaleType = taxScaleType
        self.residencyStatus = residencyStatus
        self.australianResidentForTaxPurposes = australianResidentForTaxPurposes
    }

    public enum CodingKeys: String, CodingKey {
        case taxFileNumber = "TaxFileNumber"
        case thresholdClaimed = "TaxFreeThresholdClaimed"
        case hasLoansOrDebt = "HasLoanOrStudentDebt"

        case employeeId = "EmployeeID"
        case employmentBasis = "EmploymentBasis"
        case exemptionType = "TFNExemptionType"

        case taxScaleType = "TaxScaleType"
        case residencyStatus = "ResidencyStatus"
        case australianResidentForTaxPurposes = "AustralianResidentForTaxPurposes"
    }
}
