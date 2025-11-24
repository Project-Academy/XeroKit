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
    public var earnings: [EarningsLine]
//    public var deductions: [DeductionLine]
//    public var superLines: [SuperLine]
//    public var reimbursements: [ReimbursementLine]
//    public var leaveLines: [LeaveLine]
    
    enum CodingKeys: String, CodingKey {
        case earnings = "EarningsLines"
//        case deductions = "DeductionLines"
//        case superLines = "SuperLines"
//        case reimbursements = "ReimbursementLines"
//        case leaveLines = "LeaveLines"
    }
}

public struct EarningsLine: Codable {
    
}
