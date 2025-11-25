//
//  Payslip.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

public struct Payslip: Codable {
    
    //--------------------------------------
    // MARK: - ID VARIABLES -
    //--------------------------------------
    public let payslipId: String
    public let employeeId: String
    public let fName: String
    public let lName: String
    
    //--------------------------------------
    // MARK: - SLIP VARIABLES -
    //--------------------------------------
    public var earningsLines: [EarningsLine]?
//    var TimesheetEarningsLines: Array<TimesheetEarningsLine>?
//    var DeductionLines:         Array<DeductionLine>?
//    var LeaveEarningsLines:     Array<LeaveEarningsLine>?
//    var LeaveAccrualLines:      Array<LeaveAccrualLine>?
//    var ReimbursementLines:     Array<ReimbursementLine>?
//    var SuperannuationLines:    Array<SuperannuationLine>?
//    var TaxLines:               Array<TaxLine>?
    
    //--------------------------------------
    // MARK: - SUMMARY VARS -
    //--------------------------------------
    public var wages: Double?
    public var deductions: Double?
    public var tax: Double?
    public var `super`: Double?
    public var reimbursements: Double?

    public var netPay: Double?

    //--------------------------------------
    // MARK: - MISC VARS -
    //--------------------------------------
    @DateString var LastEdited: Date?
    @DateString var UpdatedDateUTC: Date?
    
    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case payslipId = "PayslipID"
        case employeeId = "EmployeeID"
        case fName = "FirstName"
        case lName = "LastName"
        
        case earningsLines = "EarningsLines"
//        case timesheetLines = "TimesheetEarningsLines"
//        case deductionLines = "DeductionLines"
//        case leaveLines = "LeaveEarningsLines"
//        case leaveAccrualLines = "LeaveAccrualLines"
//        case reimbursementLines = "ReimbursementLines"
//        case superannuationLines = "SuperannuationLines"
//        case taxLines = "TaxLines"
        
        case wages = "Wages"
        case deductions = "Deductions"
        case tax = "Tax"
        case `super` = "Super"
        case reimbursements = "Reimbursements"
        
        case netPay = "NetPay"
        
        case LastEdited
        case UpdatedDateUTC
    }
}
