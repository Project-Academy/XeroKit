//
//  API+Payslips.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

extension Payslip {

    /**
     POSTs an updated set of EarningsLines for the Payslip identified by
     `id`. Returns the updated Payslip echoed back by Xero in the response.

     Note: Xero's POST `/Payslip/<id>` envelope uses a plural `Payslips`
     array (one element), unlike the GET on the same URL which returns a
     singular `Payslip` key — so this method decodes a separate
     `PayslipUpdateResponse`.
     */
    public static func update(id: String, with earningsLines: [EarningsLine], retryPolicy policy: RetryPolicy = .retry) async throws -> Payslip {
        let lines = earningsLines.compactMap(\.json)
        let decoded = try await API.Payslips.with(id).POST
            .params(["EarningsLines": lines])
            .paramTransformer { dict in
                try JSONSerialization.data(withJSONObject: [dict], options: .prettyPrinted)
            }
            .retryPolicy(policy)
            .response()
            .asType(PayslipUpdateResponse.self)
        guard let slip = decoded.payslips.first
        else { throw FetchError.noItemsFound }
        return slip
    }

    /**
     Retrieve a Payslip given the ID

     This modifier can be used to set common headers like `Authorization` or custom headers.
     The header is stored internally and applied to the `urlRequest` when `build()` is called.

     - Parameters:
       - id: The PayslipId you wish to fetch from the Xero API.
       - policy: The retry policy to apply to API requests. Defaults to `.retry`.
     - Returns: A Xero Payslip object corresponding to the payslip ID.
     */
    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> Payslip {
        var slip = try await API.Payslips.with(id).GET
            .retryPolicy(policy)
            .response()
            .asType(PayslipsResponse.self)
            .slip

        let _ratesArray: [EarningsRate_Template]
        if let data = UserDefaults.standard.data(forKey: "XEROKIT_EARNINGS_RATES_LIST"),
           let ratesList = try? JSONDecoder().decode([EarningsRate_Template].self, from: data) {
            _ratesArray = ratesList
        } else { _ratesArray = try await EarningsRate_Template.list(retryPolicy: policy) }
        var earningsDict: PayRatesDict = [:]
        for line in slip.earningsLines ?? [] {
            guard let eRate = _ratesArray.first(where: { $0.rateId == line.rateId }),
                  let rateValue = line.rateValue
            else { continue }
            earningsDict[eRate.rate] = .init(rate: eRate.rate, basis: eRate.basis, value: rateValue)
        }
        slip.earningsDict = earningsDict
        
        return slip
    }
    
}

extension API {
    enum Payslips: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "1.0/Payslip")

        case with(_ id: String)

        var path: URL {
            switch self {
            case .with(let id): Self.base.appending(path: id)
            }
        }
    }
}

/// GET `/Payslip/<id>` envelope. Singular `Payslip` key.
struct PayslipsResponse: Decodable, XeroV1Response {
    let slip: Payslip

    public let id: String
    public let source: String
    public let status: String
    @DateString var utcDate: Date?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case source = "ProviderName"
        case status = "Status"
        case utcDate = "DateTimeUTC"

        case slip = "Payslip"
    }
}

/// POST `/Payslip/<id>` envelope. Plural `Payslips` array (one element).
struct PayslipUpdateResponse: Decodable, XeroV1Response {
    let payslips: [Payslip]

    public let id: String
    public let source: String
    public let status: String
    @DateString var utcDate: Date?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case source = "ProviderName"
        case status = "Status"
        case utcDate = "DateTimeUTC"

        case payslips = "Payslips"
    }
}
