//
//  API+Employees.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation


extension Employee {

    /**
     Fetches every Employee on the Xero org, auto-paginating until the
     server returns fewer than the per-page max (100 — Xero's limit).
     */
    public static func list(retryPolicy policy: RetryPolicy = .retry) async throws -> [Employee] {
        try await Xero.paginated(
            from: API.Employees.list.GET,
            envelope: EmployeesResponse.self,
            retryPolicy: policy
        )
    }

    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> Employee {
        let employees = try await API.Employees.with(id).GET
            .retryPolicy(policy)
            .response()
            .asType(EmployeesResponse.self)
            .resource
        guard !employees.isEmpty
        else { throw EmployeesError.noEmployeesFound }
        guard employees.count == 1, let employee = employees.first
        else { throw EmployeesError.multipleEmployeesFound }
        return employee
    }

    /**
     Creates the receiver on Xero via POST `/Employees`. Xero requires
     the body shape to be an array even for a single entity — see
     `Request.arrayWrappedJSONBody()`.
     */
    public func create(retryPolicy policy: RetryPolicy = .retry) async throws -> Employee {
        guard let json = self.json
        else { throw EmployeesError.noEmployeesFound }
        let employees = try await API.Employees.list.POST
            .params(json)
            .arrayWrappedJSONBody()
            .retryPolicy(policy)
            .response()
            .asType(EmployeesResponse.self)
            .resource
        guard let created = employees.first
        else { throw EmployeesError.noEmployeesFound }
        return created
    }

    /**
     Updates an existing Employee on Xero by POSTing the full
     representation to `/Employees`. Xero treats a POST with a known
     `EmployeeID` as an upsert.
     */
    public static func update(_ employee: Employee, retryPolicy policy: RetryPolicy = .retry) async throws -> Employee {
        guard let json = employee.json
        else { throw EmployeesError.noEmployeesFound }
        let employees = try await API.Employees.list.POST
            .params(json)
            .arrayWrappedJSONBody()
            .retryPolicy(policy)
            .response()
            .asType(EmployeesResponse.self)
            .resource
        guard let updated = employees.first
        else { throw EmployeesError.noEmployeesFound }
        return updated
    }

    public func fetchRates(retryPolicy policy: RetryPolicy = .retry) async throws -> PayRatesDict {
        guard let employeeId
        else { throw EmployeesError.missingEmployeeID }
        return try await EarningsRate_Template.payRates(for: employeeId, retryPolicy: policy)
    }
}

//--------------------------------------
// MARK: - ENDPOINTS -
//--------------------------------------
extension API {
    enum Employees: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "1.0/Employees")

        case list
        case with(_ id: String)

        var path: URL {
            switch self {
            case .list:         Self.base
            case .with(let id): Self.base.appending(path: id)
            }
        }
    }
}

//--------------------------------------
// MARK: - RESPONSE -
//--------------------------------------
internal struct EmployeesResponseKey: XeroResponseKey {
    static let jsonKey = "Employees"
}
internal typealias EmployeesResponse = XeroV1Envelope<[Employee], EmployeesResponseKey>
