//
//  API+EarningsRates.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

extension EarningsRate {
    
    public static func list() async throws -> [EarningsRate] {
        let response = try await API.EarningsRates.list.GET
            .response()
            .asType(EarningsRatesResponse.self)
        
        let data = try JSONEncoder().encode(response.earningsRates)
        UserDefaults.standard.set(data, forKey: "XEROKIT_EARNINGS_RATES_LIST")
        
        return response.earningsRates
    }
    
    public static func with(id: String) async throws -> EarningsRate {
        let rate = try await API.EarningsRates.with(id).GET
            .response()
            .asType(SingleEarningsRatesResponse.self)
            .earningsRate
        
        return rate
    }
    
    public static func payRates(for empId: String) async throws -> [PayRate: Decimal] {
        var rates: [PayRate: Decimal] = [:]
        
        let _ratesArray: [EarningsRate]
        if let data = UserDefaults.standard.data(forKey: "XEROKIT_EARNINGS_RATES_LIST"),
           let ratesList = try? JSONDecoder().decode([EarningsRate].self, from: data) {
            _ratesArray = ratesList
        } else { _ratesArray = try await list() }
        let allRates = _ratesArray.filter { $0.type != .Other }
        
        let employee = try await Employee.with(id: empId)
        guard let earningsLines = employee.payTemplate?.earnings
        else { throw EarningsRatesError.noEarningsLines }
        
        for rate in _ratesArray {
            guard let line = earningsLines.first(where: { $0.rateId == rate.rateId })
            else { continue }
            rates[rate.type] = line.rate
        }
        
        return rates
    }
}

extension API {
    internal enum EarningsRates: Endpoints {
        typealias API = Xero
        static var base: URL = API.baseURL.appending(path: "2.0/earningsRates")
        
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

struct EarningsRatesResponse: Decodable, CustomStringConvertible, XeroV2Response {
    
    public let earningsRates: [EarningsRate]
    
    // Default Response Variables
    public let id: String
    public let status: String
    public let source: String
    @DateString var dateUTC: Date?
    
    public let pagination: [String:Int]?
    
    // Custom Description
    public var description: String {
        let rates = earningsRates
            .compactMap { "\($0.name ?? "Unknown"), ID: \($0.rateId ?? "Unknown"), DefaultRate: \(($0.ratePerUnit ?? 0).formatted(.currency(code: "AUD")))" }
            .joined(separator: ",\n\t")
        
        return "EarningsRatesResponse(id: \(id), status: \(status), Source: \(source), dateUTC: \(dateUTC ?? .distantPast)), pagination: \(pagination)\nEarningsRates (\(earningsRates.count)): [\n\t\(rates)\n]"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case status = "httpStatusCode"
        case source = "providerName"
        case dateUTC = "dateTimeUTC"
        case pagination
        
        case earningsRates
    }
}

struct SingleEarningsRatesResponse: Decodable, XeroV2Response {
    
    public let earningsRate: EarningsRate
    
    // Default Response Variables
    public let id: String
    public let status: String
    public let source: String
    @DateString var dateUTC: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status = "httpStatusCode"
        case source = "providerName"
        case dateUTC = "dateTimeUTC"
        
        case earningsRate
    }
}
