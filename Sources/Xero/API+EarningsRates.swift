//
//  API+EarningsRates.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

extension EarningsRate_Template {

    /**
     Fetches every active EarningsRate from Xero.

     **Side effect:** the result is encoded to JSON and cached in
     `UserDefaults` under `EarningsRate_Template.cacheKey` so other
     XeroKit accessors (notably `EarningsLine.rate`) can resolve a
     `rateId` to a typed `PayRate` without an extra round trip.
     */
    public static func list(retryPolicy policy: RetryPolicy = .retry) async throws -> [EarningsRate_Template] {
        let rates = try await API.EarningsRates.list.GET
            .retryPolicy(policy)
            .response()
            .asType(EarningsRatesResponse.self)
            .resource

        if let data = try? JSONEncoder().encode(rates) {
            UserDefaults.standard.set(data, forKey: EarningsRate_Template.cacheKey)
        }

        return rates
    }

    public static func with(id: String, retryPolicy policy: RetryPolicy = .retry) async throws -> EarningsRate_Template {
        try await API.EarningsRates.with(id).GET
            .retryPolicy(policy)
            .response()
            .asType(SingleEarningsRateResponse.self)
            .resource
    }

    public static func payRates(for empId: String, retryPolicy policy: RetryPolicy = .retry) async throws -> PayRatesDict {
        var rates: PayRatesDict = [:]

        let _ratesArray: [EarningsRate_Template]
        if let data = UserDefaults.standard.data(forKey: EarningsRate_Template.cacheKey),
           let ratesList = try? JSONDecoder().decode([EarningsRate_Template].self, from: data) {
            _ratesArray = ratesList
        } else { _ratesArray = try await list(retryPolicy: policy) }

        let employee = try await Employee.with(id: empId, retryPolicy: policy)
        guard let earningsLines = employee.payTemplate?.earnings
        else { throw EarningsRatesError.noEarningsLines }

        for rate in _ratesArray {
            guard let line = earningsLines.first(where: { $0.rateId == rate.rateId }),
                  let rateValue = line.rateValue
            else { continue }
            rates[rate.rate] = .init(rate: rate.rate, basis: rate.basis, value: rateValue)
        }

        return rates
    }
}

//--------------------------------------
// MARK: - PAY RATES DICT -
//--------------------------------------
public typealias PayRatesDict = [PayRate: EarningsRate]
extension PayRatesDict {
    public var description: String {
        var desc = "["
        for rate in self {
            desc += "\(rate.key): \(rate.value.value.formatted(.currency(code: "AUD")))"
            switch rate.value.basis {
            case .perHour: desc.append("/hr")
            case .perUnit(let unit): desc.append("/\(unit)")
            case .other: break
            }
            desc.append(", ")
        }
        if desc.contains(", ") { desc.removeLast(2) }
        return desc
    }
}

//--------------------------------------
// MARK: - EARNINGS RATE -
//--------------------------------------
public struct EarningsRate: Codable, Sendable {

    public var rate: PayRate
    public var basis: EarningsBasis
    public var value: Decimal

    public init(rate: PayRate, basis: EarningsBasis, value: Decimal) {
        self.rate = rate
        self.basis = basis
        self.value = value
    }

    public static func fetchRates(employeeId: String?, retryPolicy policy: RetryPolicy = .retry) async throws -> PayRatesDict {
        guard let employeeId else { return [:] }
        return try await EarningsRate_Template.payRates(for: employeeId, retryPolicy: policy)
    }
}
extension EarningsRate: CustomStringConvertible {
    public var description: String {
        var desc = ""
        desc += "\(rate)(\(value.formatted(.currency(code: "AUD")))"
        switch basis {
        case .perHour: desc.append("/hr")
        case .perUnit(let unit): desc.append("/\(unit)")
        case .other: break
        }
        desc += ")"
        return desc
    }
}
extension EarningsRate: Equatable {}

public enum EarningsBasis: Codable, Sendable, Equatable {
    case perHour
    case perUnit(_: String)
    case other
}

//--------------------------------------
// MARK: - ENDPOINTS -
//--------------------------------------
extension API {
    internal enum EarningsRates: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "2.0/earningsRates")

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
internal struct EarningsRatesResponseKey: XeroResponseKey {
    static let jsonKey = "earningsRates"
}
internal struct SingleEarningsRateResponseKey: XeroResponseKey {
    static let jsonKey = "earningsRate"
}
internal typealias EarningsRatesResponse      = XeroV2Envelope<[EarningsRate_Template], EarningsRatesResponseKey>
internal typealias SingleEarningsRateResponse = XeroV2Envelope<EarningsRate_Template, SingleEarningsRateResponseKey>
