//
//  SuperMembership.swift
//  XeroKit
//
//  An employee's enrolment in a specific superannuation fund. Each
//  fund the employee belongs to gets a `SuperMembership`, identified
//  by `superMembershipId` (Xero-side) and `employeeNumber` (the ID
//  the super fund itself uses to recognise the employee).
//

import Foundation

public struct SuperMembership: Codable {
    public var superMembershipId: String?
    public var superFundId:       String?
    public var employeeNumber:    String?

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        superMembershipId: String? = nil,
        superFundId:       String? = nil,
        employeeNumber:    String? = nil
    ) {
        self.superMembershipId = superMembershipId
        self.superFundId       = superFundId
        self.employeeNumber    = employeeNumber
    }

    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case superMembershipId = "SuperMembershipID"
        case superFundId       = "SuperFundID"
        case employeeNumber    = "EmployeeNumber"
    }
}
