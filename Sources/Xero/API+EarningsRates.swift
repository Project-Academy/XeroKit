//
//  API+EarningsRates.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

extension EarningsRate_Template {
    
    public static func list() async throws -> [EarningsRate_Template] {
        let response = try await API.EarningsRates.list.GET
            .response()
            .asType(EarningsRatesResponse.self)
        
        let data = try JSONEncoder().encode(response.earningsRates)
        UserDefaults.standard.set(data, forKey: "XEROKIT_EARNINGS_RATES_LIST")
        
        return response.earningsRates
    }
    
    public static func with(id: String) async throws -> EarningsRate_Template {
        let rate = try await API.EarningsRates.with(id).GET
            .response()
            .asType(SingleEarningsRatesResponse.self)
            .earningsRate
        
        return rate
    }
    
    public static func payRates(for empId: String) async throws -> PayRatesDict {
        var rates: PayRatesDict = [:]
        
        let _ratesArray: [EarningsRate_Template]
        if let data = UserDefaults.standard.data(forKey: "XEROKIT_EARNINGS_RATES_LIST"),
           let ratesList = try? JSONDecoder().decode([EarningsRate_Template].self, from: data) {
            _ratesArray = ratesList
        } else { _ratesArray = try await list() }
        let allRates = _ratesArray.filter { $0.rate != .Other }
        
        let employee = try await Employee.with(id: empId)
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

public typealias PayRatesDict = [PayRate: EarningsRate]
extension PayRatesDict: CustomStringConvertible {
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
public struct EarningsRate: Codable, Sendable {
    public var rate: PayRate
    public var basis: EarningsBasis
    public var value: Decimal
    
    public static func fetchRates(employeeId: String?) async throws -> PayRatesDict {
        guard let employeeId else { return [:] }
        return try await EarningsRate_Template.payRates(for: employeeId)
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

public enum EarningsBasis: Codable, Sendable {
    case perHour
    case perUnit(_: String)
    case other
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
    
    public let earningsRates: [EarningsRate_Template]
    
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
    
    public let earningsRate: EarningsRate_Template
    
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
