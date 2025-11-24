//
//  EmploymentBasis.swift
//  XeroAPI
//
//  Created by Sarfraz Basha on 18/11/2025.
//

import Foundation

public enum EmploymentBasis: String, Codable {
    case casual     = "CASUAL"
    case fullTime   = "FULLTIME"
    case partTime   = "PARTTIME"
    case labourHire = "LABOURHIRE"
    
    /// NONEMPLOYEE will only be supported for an STP Phase 2 enabled organisation.
    case nonEmployee = "NONEMPLOYEE"
    
    @available(*, deprecated, message: "SUPERINCOMESTREAM is deprecated and will be invalid for an STP Phase 2 enabled organisation.")
    case superIncome = "SUPERINCOMESTREAM"
}
