//
//  TaxDeclaration.swift
//  XeroAPI
//
//  Created by Sarfraz Basha on 18/11/2025.
//

import Foundation

public struct TaxDeclaration: Codable {
    
    public var taxFileNumber: String
    public var thresholdClaimed: Bool
    public var hasLoansOrDebt: Bool
    
    var employeeId: String?
    var employmentBasis: EmploymentBasis
    public var exemptionType: TFNExemptionType
    
    
    public enum CodingKeys: String, CodingKey {
        case taxFileNumber = "TaxFileNumber"
        case thresholdClaimed = "TaxFreeThresholdClaimed"
        case hasLoansOrDebt = "HasLoanOrStudentDebt"
        
        case employeeId = "EmployeeID"
        case employmentBasis = "EmploymentBasis"
        case exemptionType = "TFNExemptionType"
        
    }
    
}
