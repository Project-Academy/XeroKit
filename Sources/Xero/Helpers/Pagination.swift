//
//  Pagination.swift
//  XeroKit
//
//  Generic page-accumulator used by `Employee.list` and `PayRun.list`.
//  Xero's V1 endpoints return at most 100 results per page; we
//  recursively GET the next page until one returns fewer than that
//  many.
//

import Foundation

extension Xero {
    /**
     Recursively fetches every page from a Xero V1 list endpoint
     until a page returns fewer than `pageSize` results. The endpoint
     must accept a `?page=N` query and return an array under
     `Key.jsonKey` in a V1 envelope.

     - Parameters:
       - request: The `.GET` request for the list endpoint (without `.page(_:)`).
       - envelope: The response type alias (e.g. `EmployeesResponse.self`).
       - pageSize: Xero's per-page cap. Defaults to 100.
       - retryPolicy: Retry policy applied to every page request.
     - Returns: The concatenation of every page's `resource` array.
     */
    nonisolated static func paginated<Item, Key>(
        from request: Xero.R,
        envelope: XeroV1Envelope<[Item], Key>.Type,
        pageSize: Int = 100,
        retryPolicy: RetryPolicy = .retry
    ) async throws -> [Item] where Item: Decodable, Key: XeroResponseKey {
        try await fetchPage(
            from: request,
            envelope: envelope,
            page: 1,
            accumulated: [],
            pageSize: pageSize,
            retryPolicy: retryPolicy
        )
    }

    nonisolated private static func fetchPage<Item, Key>(
        from request: Xero.R,
        envelope: XeroV1Envelope<[Item], Key>.Type,
        page: Int,
        accumulated: [Item],
        pageSize: Int,
        retryPolicy: RetryPolicy
    ) async throws -> [Item] where Item: Decodable, Key: XeroResponseKey {
        let pageItems = try await request
            .page(page)
            .retryPolicy(retryPolicy)
            .response()
            .asType(envelope)
            .resource
        let combined = accumulated + pageItems
        guard pageItems.count == pageSize else { return combined }
        return try await fetchPage(
            from: request,
            envelope: envelope,
            page: page + 1,
            accumulated: combined,
            pageSize: pageSize,
            retryPolicy: retryPolicy
        )
    }
}
