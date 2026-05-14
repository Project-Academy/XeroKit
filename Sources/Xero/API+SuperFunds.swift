//
//  API+SuperFunds.swift
//  XeroKit
//
//  Read API surface for SuperFund. `fetchAll()` returns every super
//  fund the Xero org has on record — typically a small set used by
//  the consumer to map fund IDs to display names.
//

import Foundation

extension SuperFund {

    /**
     Fetches every SuperFund on the org. Xero's super-funds endpoint
     doesn't paginate (the list is short — usually under 50), so this
     is one round trip regardless.
     */
    public static func list(retryPolicy policy: RetryPolicy = .retry) async throws -> [SuperFund] {
        try await API.SuperFunds.list.GET
            .retryPolicy(policy)
            .response()
            .asType(SuperFundsResponse.self)
            .superFunds
    }
}

//--------------------------------------
// MARK: - ENDPOINTS -
//--------------------------------------
extension API {
    enum SuperFunds: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "1.0/SuperFunds")

        case list

        var path: URL {
            switch self {
            case .list: Self.base
            }
        }
    }
}

//--------------------------------------
// MARK: - RESPONSE -
//--------------------------------------
internal struct SuperFundsResponse: Decodable, XeroV1Response {
    let superFunds: [SuperFund]

    let id:      String
    let source:  String
    let status:  String
    @DateString var utcDate: Date?

    enum CodingKeys: String, CodingKey {
        case id      = "Id"
        case source  = "ProviderName"
        case status  = "Status"
        case utcDate = "DateTimeUTC"

        case superFunds = "SuperFunds"
    }
}
