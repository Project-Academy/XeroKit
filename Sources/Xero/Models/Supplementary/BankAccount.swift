//
//  BankAccount.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 13/11/2025.
//


import Foundation

public struct BankAccount: Codable {

    /// The text that will appear on your employee's bank statement when they receive payment
    public var statementText:   String?
    /// The name of the account
    public var accountName:     String?
    /// The BSB number of the account
    public var BSB:             String?
    /// The account number
    public var accountNumber:   String?
    /// If this account is the Remaining bank account
    public var remainder:       Bool?
    /// Fixed amounts (for example, if an employee wants to have $100 of
    /// their salary transferred to one account, and the remaining amount
    /// to another)
    public var amount:          Double?

    //--------------------------------------
    // MARK: - INITIALISER -
    //--------------------------------------
    public init(
        name: String,
        BSB: String,
        ACC: String
    ) {
        self.accountName    = name
        self.BSB            = BSB
        self.accountNumber  = ACC
        self.statementText  = "Project Pay"
    }
    
    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case statementText  = "StatementText"
        case accountName    = "AccountName"
        case BSB            = "BSB"
        case accountNumber  = "AccountNumber"
        case remainder      = "Remainder"
        case amount         = "Amount"
    }
}
