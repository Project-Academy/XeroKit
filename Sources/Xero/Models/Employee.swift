//
//  Employee.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 13/11/2025.
//

import Foundation

public struct Employee: Codable {

    public var employeeId: String?

    //--------------------------------------
    // MARK: - PERSONAL DETAILS -
    //--------------------------------------
    public var title: String?
    public var fName: String
    public var mNames: String?
    public var lName: String

    @DateString
    public var birthDate: Date?
    public var gender: Gender?

    //--------------------------------------
    // MARK: - CONTACT DETAILS -
    //--------------------------------------
    public var email: String?
    public var phone: String?
    public var mobile: String?
    public var address: Address?

    //--------------------------------------
    // MARK: - EMPLOYMENT DETAILS -
    //--------------------------------------
    @DateString
    public var startDate: Date?
    public var payCalID: String?
    public var jobTitle: String?
    public var classification: String?
    public var ordinaryEarningsRateID: String?
    public var employeeGroupName: String?
    public var status: Status?
    public var employmentType: EmploymentType?
    public var incomeType: IncomeType?

    public var terminationDate: String?
    public var terminationReason: TerminationReason?

    //--------------------------------------
    // MARK: - BANKING / TAX / SUPER / PAY -
    //--------------------------------------
    public var taxDeclaration: TaxDeclaration?
    public var bankAccounts: [BankAccount]?
    public var superMemberships: [SuperMembership]?
    public var payTemplate: PayTemplate?

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(fName: String, lName: String) {
        self.fName = fName
        self.lName = lName
    }

    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case employeeId = "EmployeeID"

        case title = "Title"
        case fName = "FirstName"
        case mNames = "MiddleNames"
        case lName = "LastName"

        case birthDate = "DateOfBirth"
        case gender = "Gender"

        case email = "Email"
        case phone = "Phone"
        case mobile = "Mobile"
        case address = "HomeAddress"

        case startDate = "StartDate"
        case payCalID = "PayrollCalendarID"
        case jobTitle = "JobTitle"
        case classification = "Classification"
        case ordinaryEarningsRateID = "OrdinaryEarningsRateID"
        case employeeGroupName = "EmployeeGroupName"
        case status = "Status"
        case employmentType = "EmploymentType"
        case incomeType = "IncomeType"
        case terminationDate = "TerminationDate"
        case terminationReason = "TerminationReason"

        case taxDeclaration = "TaxDeclaration"
        case bankAccounts = "BankAccounts"
        case superMemberships = "SuperMemberships"
        case payTemplate = "PayTemplate"
    }
}
extension Employee: CustomStringConvertible {
    public var description: String {
        "(\(fName) \(lName), ID: \(employeeId ?? "-"))"
    }
}
