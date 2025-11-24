//
//  AllowanceType.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

public enum AllowanceType: String, Codable {
    case car = "CAR"
    case transport = "TRANSPORT"
    case travel = "TRAVEL"
    case laundry = "LAUNDRY"
    case meals = "MEALS"
    case tools = "TOOLS"
    case tasks = "TASKS"
    case qualifications = "QUALIFICATIONS"
    /// Allowances of type OTHER can optionally add an ``AllowanceCategory``
    case other = "OTHER"
}
