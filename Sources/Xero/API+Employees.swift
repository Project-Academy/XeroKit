//
//  Employees.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation


extension Employee {
    
    public static func list() async throws -> [Employee] {
        try await API.Employees.list.GET
            .response()
            .asType(EmployeesResponse.self)
            .employees
    }
    
    public static func with(id: String) async throws -> Employee {
        let response = try await API.Employees.with(id).GET
            .response()
            .asType(EmployeesResponse.self)
        let employees = response.employees
        guard employees.count > 0
        else { throw EmployeesError.noEmployeesFound }
        
        guard employees.count == 1,
              let employee = employees.first
        else { throw EmployeesError.multipleEmployeesFound }
        
        return employee
    }
    
}

extension API {
    enum Employees: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "1.0/Employees")
        
        case list
        case with(_ id: String)
        
        var path: URL {
            switch self {
            case .list: Self.base
            case .with(let id): Self.base.appending(path: id)
            }
        }
    }
}

public struct EmployeesResponse: Decodable, XeroV1Response {
    public let employees: [Employee]
    
    public let id: String
    public let source: String
    public let status: String
    
    @DateString
    public var utcDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case source = "ProviderName"
        case status = "Status"
        case utcDate = "DateTimeUTC"
        
        case employees = "Employees"
    }
}
