//
//  SuperFund.swift
//  XeroKit
//
//  Represents a single superannuation fund recognised by the Xero
//  organisation. Each fund is either `regulated` (an industry fund
//  identified by USI) or an `smsf` (self-managed fund with its own
//  bank details + electronic service address).
//

import Foundation

public struct SuperFund: Codable {

    public var superFundId:    String?
    public var name:           String?
    public var type:           FundType?
    /// Australian Business Number — present for both regulated and SMSF funds.
    public var abn:            String?
    /// Some funds assign a unique number to each employer.
    public var employerNumber: String?

    //--------------------------------------
    // MARK: - SMSF-SPECIFIC -
    //--------------------------------------
    public var accountName:              String?
    public var electronicServiceAddress: String?
    public var bsb:                      String?
    public var accountNumber:            String?

    //--------------------------------------
    // MARK: - REGULATED-SPECIFIC -
    //--------------------------------------
    /// Unique Superannuation Identifier — for regulated funds only.
    public var usi: String?

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        superFundId:              String? = nil,
        name:                     String? = nil,
        type:                     FundType? = nil,
        abn:                      String? = nil,
        employerNumber:           String? = nil,
        accountName:              String? = nil,
        electronicServiceAddress: String? = nil,
        bsb:                      String? = nil,
        accountNumber:            String? = nil,
        usi:                      String? = nil
    ) {
        self.superFundId              = superFundId
        self.name                     = name
        self.type                     = type
        self.abn                      = abn
        self.employerNumber           = employerNumber
        self.accountName              = accountName
        self.electronicServiceAddress = electronicServiceAddress
        self.bsb                      = bsb
        self.accountNumber            = accountNumber
        self.usi                      = usi
    }

    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case superFundId              = "SuperFundID"
        case name                     = "Name"
        case type                     = "Type"
        case abn                      = "ABN"
        case employerNumber           = "EmployerNumber"
        case accountName              = "AccountName"
        case electronicServiceAddress = "ElectronicServiceAddress"
        case bsb                      = "BSB"
        case accountNumber            = "AccountNumber"
        case usi                      = "USI"
    }

    //--------------------------------------
    // MARK: - FUND TYPE -
    //--------------------------------------
    public enum FundType: String, Codable {
        case regulated = "REGULATED"
        case smsf      = "SMSF"
    }
}
