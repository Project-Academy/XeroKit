//
//  PayRun.swift
//  XeroKit
//
//  Represents a single pay run on Xero. A pay run is the unit that
//  groups payslips for a payroll calendar over a period — it can be
//  in DRAFT (editable) or POSTED (finalised, immutable) state.
//

import Foundation

public struct PayRun: Codable, Sendable {

    //--------------------------------------
    // MARK: - IDS / STATE -
    //--------------------------------------
    /// Unique identifier for this PayRun (Xero-assigned on create).
    public var payRunId: String?
    /// Payroll Calendar this PayRun belongs to. Determines period
    /// boundaries + which employees are included.
    public var payrollCalendarId: String?
    /// Either `DRAFT` (editable) or `POSTED` (finalised).
    public var status: Status?

    //--------------------------------------
    // MARK: - DATES -
    //--------------------------------------
    @DateString public var paymentDate:           Date?
    @DateString public var payRunPeriodStartDate: Date?
    @DateString public var payRunPeriodEndDate:   Date?

    public var payslipMessage: String?

    //--------------------------------------
    // MARK: - TOTALS -
    //--------------------------------------
    /// Total gross wages across all payslips in this run.
    public var wages:          Double?
    public var deductions:     Double?
    public var tax:            Double?
    /// Reserved word — backtick-escaped property name.
    public var `super`:        Double?
    public var reimbursement:  Double?
    public var netPay:         Double?

    //--------------------------------------
    // MARK: - PAYSLIPS -
    //--------------------------------------
    /**
     The payslips inside this pay run. Only populated when fetching a
     specific PayRun by ID — the `fetchAll` list endpoint returns
     summary rows without payslips, so this stays nil there.
     */
    public var payslips: [Payslip]?

    @DateString var updatedDateUTC: Date?

    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case payRunId             = "PayRunID"
        case payrollCalendarId    = "PayrollCalendarID"
        case status               = "PayRunStatus"

        case paymentDate          = "PaymentDate"
        case payRunPeriodStartDate = "PayRunPeriodStartDate"
        case payRunPeriodEndDate   = "PayRunPeriodEndDate"
        case payslipMessage       = "PayslipMessage"

        case wages                = "Wages"
        case deductions           = "Deductions"
        case tax                  = "Tax"
        case `super`              = "Super"
        case reimbursement        = "Reimbursement"
        case netPay               = "NetPay"

        case payslips             = "Payslips"
        case updatedDateUTC       = "UpdatedDateUTC"
    }

    //--------------------------------------
    // MARK: - STATUS -
    //--------------------------------------
    public enum Status: String, Codable, Sendable {
        case DRAFT
        case POSTED
    }
}
