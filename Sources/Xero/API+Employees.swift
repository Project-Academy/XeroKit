//
//  Employees.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation


extension Employee {

    /**
     Fetches every Employee on the Xero org, auto-paginating until the
     server returns fewer than the per-page max (100 — Xero's limit).
     The recursive accumulator is the simplest correct form; for a
     1000-person org this is ~10 sequential GETs.
     */
    public static func list(retryPolicy policy: RetryPolicy = .retry) async throws -> [Employee] {
        try await fetchPage(1, accumulated: [], retryPolicy: policy)
    }

    private static func fetchPage(
        _ page: Int,
        accumulated: [Employee],
        retryPolicy policy: RetryPolicy
    ) async throws -> [Employee] {
        let pageOfEmployees = try await API.Employees.list.GET
            .page(page)
            .retryPolicy(policy)
            .response()
            .asType(EmployeesResponse.self)
            .employees
        let combined = accumulated + pageOfEmployees
        // Xero caps each page at 100. Fewer than 100 means we've hit
        // the end and no further fetch is needed.
        guard pageOfEmployees.count == 100 else { return combined }
        return try await fetchPage(page + 1, accumulated: combined, retryPolicy: policy)
    }

    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> Employee {
        let response = try await API.Employees.with(id).GET
            .retryPolicy(policy)
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

    /**
     Creates the receiver on Xero via POST `/Employees`. Xero requires
     the body shape to be an array even for a single entity, so we
     swap the request's `paramTransformer` to wrap the dict in `[ ... ]`
     before serialising.

     Returns the Xero-side Employee echoed back in the response (now
     populated with `employeeId`).
     */
    public func create(retryPolicy policy: RetryPolicy = .retry) async throws -> Employee {
        guard let json = self.json
        else { throw EmployeesError.noEmployeesFound }
        let response = try await API.Employees.list.POST
            .params(json)
            .paramTransformer { dict in
                try JSONSerialization.data(withJSONObject: [dict], options: .prettyPrinted)
            }
            .retryPolicy(policy)
            .response()
            .asType(EmployeesResponse.self)
        guard let created = response.employees.first
        else { throw EmployeesError.noEmployeesFound }
        return created
    }

    /**
     Updates an existing Employee on Xero by POSTing the full
     representation to `/Employees`. Xero treats a POST with a known
     `EmployeeID` as an upsert.

     Same `[dict]` body wrapping trick as `create()`.
     */
    public static func update(
        _ employee: Employee,
        retryPolicy policy: RetryPolicy = .retry
    ) async throws -> Employee {
        guard let json = employee.json
        else { throw EmployeesError.noEmployeesFound }
        let response = try await API.Employees.list.POST
            .params(json)
            .paramTransformer { dict in
                try JSONSerialization.data(withJSONObject: [dict], options: .prettyPrinted)
            }
            .retryPolicy(policy)
            .response()
            .asType(EmployeesResponse.self)
        guard let updated = response.employees.first
        else { throw EmployeesError.noEmployeesFound }
        return updated
    }

    public func fetchRates(retryPolicy policy: RetryPolicy = .retry) async throws -> PayRatesDict {
        guard let employeeId else { fatalError() }
        return try await EarningsRate_Template.payRates(for: employeeId, retryPolicy: policy)
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

internal struct EmployeesResponse: Decodable, XeroV1Response {
    public let employees: [Employee]
    
    // Default Response Variables
    public let id: String
    public let source: String
    public let status: String
    @DateString var utcDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case source = "ProviderName"
        case status = "Status"
        case utcDate = "DateTimeUTC"
        
        case employees = "Employees"
    }
}
