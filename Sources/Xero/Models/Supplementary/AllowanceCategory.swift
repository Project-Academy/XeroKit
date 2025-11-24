//
//  AllowanceCategory.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

public enum AllowanceCategory: String, Codable {
    case nondeductible = "NONDEDUCTIBLE"
    case uniform = "UNIFORM"
    case privateVehicle = "PRIVATEVEHICLE"
    case homeOffice = "HOMEOFFICE"
    case transport = "TRANSPORT"
    case general = "GENERAL"
    case other = "OTHER"
}
