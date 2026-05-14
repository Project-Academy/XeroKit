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

    public static func list(retryPolicy policy: RetryPolicy = .retry) async throws -> [PayRun] {
        try await Xero.paginated(
            from: API.PayRuns.list.GET,
            envelope: PayRunsResponse.self,
            retryPolicy: policy
        )
    }

    /**
     Fetches the single PayRun matching `id`, including its full
     payslip list. The list endpoint omits payslips, so use this
     when you actually need to operate on the contained payslips.
     */
    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> PayRun {
        let runs = try await API.PayRuns.with(id).GET
            .retryPolicy(policy)
            .response()
            .asType(PayRunsResponse.self)
            .resource
        guard let run = runs.first
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
            .resource
    }

    /**
     Creates a new DRAFT PayRun against the given payroll calendar.
     Xero returns the created PayRun echoed back with its assigned
     `payRunId`. Body uses the standard array-wrapped form via
     `Request.arrayWrappedJSONBody()`.
     */
    public static func create(forCalendarId calendarId: String, retryPolicy policy: RetryPolicy = .retry) async throws -> PayRun {
        let runs = try await API.PayRuns.list.POST
            .params(["PayrollCalendarID": calendarId])
            .arrayWrappedJSONBody()
            .retryPolicy(policy)
            .response()
            .asType(PayRunsResponse.self)
            .resource
        guard let created = runs.first
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
internal struct PayRunsResponseKey: XeroResponseKey {
    static let jsonKey = "PayRuns"
}
internal typealias PayRunsResponse = XeroV1Envelope<[PayRun], PayRunsResponseKey>
