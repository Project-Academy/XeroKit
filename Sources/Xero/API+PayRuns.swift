//
//  API+PayRuns.swift
//  XeroKit
//
//  Read + write API surface for PayRuns:
//  - `list()`     — fetch every PayRun on the org (paginated)
//  - `with(id:)`  — fetch a single PayRun, including its payslips
//  - `drafts()`   — list only DRAFT-status PayRuns
//  - `create(forCalendarId:)` — POST a new DRAFT PayRun for the given calendar
//

import Foundation

extension PayRun {

    /**
     Fetches every PayRun on the Xero org, auto-paginating until the
     server returns fewer than the per-page max (100). Like
     `Employee.list`, this is a sequential recursive accumulator —
     typical orgs have a small handful of PayRuns so this is one or
     two GETs in practice.
     */
    public static func list(retryPolicy policy: RetryPolicy = .retry) async throws -> [PayRun] {
        try await fetchPage(1, accumulated: [], retryPolicy: policy)
    }

    private static func fetchPage(
        _ page: Int,
        accumulated: [PayRun],
        retryPolicy policy: RetryPolicy
    ) async throws -> [PayRun] {
        let pageOfRuns = try await API.PayRuns.list.GET
            .page(page)
            .retryPolicy(policy)
            .response()
            .asType(PayRunsResponse.self)
            .payRuns
        let combined = accumulated + pageOfRuns
        guard pageOfRuns.count == 100 else { return combined }
        return try await fetchPage(page + 1, accumulated: combined, retryPolicy: policy)
    }

    /**
     Fetches the single PayRun matching `id`, including its full
     payslip list. The list endpoint omits payslips, so use this
     when you actually need to operate on the contained payslips.
     */
    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> PayRun {
        let response = try await API.PayRuns.with(id).GET
            .retryPolicy(policy)
            .response()
            .asType(PayRunsResponse.self)
        guard let run = response.payRuns.first
        else { throw FetchError.noItemsFound }
        return run
    }

    /**
     Convenience filter: fetches all DRAFT-status PayRuns. Server-side
     filter via Xero's `where` query param, so this is a single GET
     regardless of how many POSTED runs the org has.

     - Note: still capped at 100 results by Xero's per-page limit.
       Orgs typically have at most a couple of drafts at a time.
     */
    public static func drafts(retryPolicy policy: RetryPolicy = .retry) async throws -> [PayRun] {
        try await API.PayRuns.list.GET
            .where("PayRunStatus==\"DRAFT\"")
            .retryPolicy(policy)
            .response()
            .asType(PayRunsResponse.self)
            .payRuns
    }

    /**
     Creates a new DRAFT PayRun against the given payroll calendar
     (`PayrollCalendarID`). Xero returns the created PayRun echoed
     back with its assigned `payRunId`. Body is the standard
     `[{ ... }]` array-wrapped form Xero requires for write endpoints.
     */
    public static func create(
        forCalendarId calendarId: String,
        retryPolicy policy: RetryPolicy = .retry
    ) async throws -> PayRun {
        let response = try await API.PayRuns.list.POST
            .params(["PayrollCalendarID": calendarId])
            .paramTransformer { dict in
                try JSONSerialization.data(withJSONObject: [dict], options: .prettyPrinted)
            }
            .retryPolicy(policy)
            .response()
            .asType(PayRunsResponse.self)
        guard let created = response.payRuns.first
        else { throw FetchError.noItemsFound }
        return created
    }
}

//--------------------------------------
// MARK: - ENDPOINTS -
//--------------------------------------
extension API {
    enum PayRuns: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "1.0/PayRuns")

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
internal struct PayRunsResponse: Decodable, XeroV1Response {
    let payRuns: [PayRun]

    // Default response envelope
    let id:      String
    let source:  String
    let status:  String
    @DateString var utcDate: Date?

    enum CodingKeys: String, CodingKey {
        case id      = "Id"
        case source  = "ProviderName"
        case status  = "Status"
        case utcDate = "DateTimeUTC"

        case payRuns = "PayRuns"
    }
}
