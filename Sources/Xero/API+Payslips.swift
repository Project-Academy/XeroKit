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

     - Note: Xero's POST `/Payslip/<id>` envelope uses a plural `Payslips`
       array (one element), unlike the GET on the same URL which returns
       a singular `Payslip` key — hence the separate `PayslipUpdateResponse`.
     */
    public static func update(id: String, with earningsLines: [EarningsLine], retryPolicy policy: RetryPolicy = .retry) async throws -> Payslip {
        let lines = earningsLines.compactMap(\.json)
        let payslips = try await API.Payslips.with(id).POST
            .params(["EarningsLines": lines])
            .arrayWrappedJSONBody()
            .retryPolicy(policy)
            .response()
            .asType(PayslipUpdateResponse.self)
            .resource
        guard let slip = payslips.first
        else { throw FetchError.noItemsFound }
        return slip
    }

    /**
     Retrieves the Payslip with the given `id`, decorating it with a
     `earningsDict` populated by mapping each `EarningsLine.rateId` to
     a typed `PayRate` via the cached `EarningsRate_Template` list.
     */
    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> Payslip {
        var slip = try await API.Payslips.with(id).GET
            .retryPolicy(policy)
            .response()
            .asType(PayslipsResponse.self)
            .resource

        let _ratesArray: [EarningsRate_Template]
        if let data = UserDefaults.standard.data(forKey: EarningsRate_Template.cacheKey),
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

//--------------------------------------
// MARK: - ENDPOINTS -
//--------------------------------------
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

//--------------------------------------
// MARK: - RESPONSE -
//--------------------------------------
/// GET `/Payslip/<id>` — envelope key is singular `Payslip`.
internal struct PayslipResponseKey: XeroResponseKey {
    static let jsonKey = "Payslip"
}
/// POST `/Payslip/<id>` — envelope key is plural `Payslips`, even though
/// the array always contains exactly one element.
internal struct PayslipsResponseKey: XeroResponseKey {
    static let jsonKey = "Payslips"
}
internal typealias PayslipsResponse       = XeroV1Envelope<Payslip,   PayslipResponseKey>
internal typealias PayslipUpdateResponse  = XeroV1Envelope<[Payslip], PayslipsResponseKey>
