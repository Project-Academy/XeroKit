//
//  IncomeType.swift
//  XeroKit
//

import Foundation

public enum IncomeType: String, Codable {
    case salaryAndWages       = "SALARYANDWAGES"
    case workingHolidayMaker  = "WORKINGHOLIDAYMAKER"
    case nonEmployee          = "NONEMPLOYEE"
    case closelyHeldPayees    = "CLOSELYHELDPAYEES"
    case labourHire           = "LABOURHIRE"
}
