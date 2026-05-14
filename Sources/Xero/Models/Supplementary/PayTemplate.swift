//
//  PayTemplate.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 13/11/2025.
//

import Foundation

/**
 This object represents an Employee's 'default' Payslip.
 As the name suggests, this is the template that is used to generate a payslip for the TM during a pay run.

 On Xero, this is where we fetch and store a TM's pay rates.

 */
public struct PayTemplate: Codable {
    public var earnings: [EarningsLine]?
    public var superLines: [SuperLine]?
//    public var deductions: [DeductionLine]
//    public var reimbursements: [ReimbursementLine]
//    public var leaveLines: [LeaveLine]

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        earnings: [EarningsLine]? = nil,
        superLines: [SuperLine]? = nil
    ) {
        self.earnings = earnings
        self.superLines = superLines
    }

    enum CodingKeys: String, CodingKey {
        case earnings = "EarningsLines"
        case superLines = "SuperLines"
//        case deductions = "DeductionLines"
//        case reimbursements = "ReimbursementLines"
//        case leaveLines = "LeaveLines"
    }
}

public struct EarningsLine: Codable {
    /// Xero earnings rate identifier.
    /// Corresponds to ``EarningsRate_Template``'s ``rateId`` property.
    public var rateId: String?
    /// Rate per unit of the EarningsLine
    public var rateValue: Decimal?

    /// Possible values: `earningsRate`, `enterRate`, and `salary`.
    /// In Project's context, almost always `enterRate`.
    public var calcType: RateCalcType?

    /// Hours per week for the EarningsLine.
    /// Applicable for `ANNUALSALARY` ``RateCalcType``
    public var unitsPerWeek: Int?
    /// Annual Salary of employee
    public var salary: Decimal?
    /// Normal number of units for EarningsLine.
    /// Applicable when ``RateType`` is `MULTIPLE`
    public var normalNumberOfUnits: Decimal?

    public var rate: PayRate? {
        guard let data = UserDefaults.standard.data(forKey: "XEROKIT_EARNINGS_RATES_LIST"),
              let ratesList = try? JSONDecoder().decode([EarningsRate_Template].self, from: data),
              let rate = ratesList.first(where: { $0.rateId == self.rateId })?.rate
        else { return nil }
        return rate
    }

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        rateId: String? = nil,
        rateValue: Decimal? = nil,
        calcType: RateCalcType? = nil,
        unitsPerWeek: Int? = nil,
        salary: Decimal? = nil,
        normalNumberOfUnits: Decimal? = nil
    ) {
        self.rateId = rateId
        self.rateValue = rateValue
        self.calcType = calcType
        self.unitsPerWeek = unitsPerWeek
        self.salary = salary
        self.normalNumberOfUnits = normalNumberOfUnits
    }

    enum CodingKeys: String, CodingKey {
        case rateId = "EarningsRateID"
        case rateValue = "RatePerUnit"
        case calcType = "CalculationType"
        case unitsPerWeek = "NumberOfUnitsPerWeek"
        case salary = "AnnualSalary"
        case normalNumberOfUnits = "NormalNumberOfUnits"
    }
}
