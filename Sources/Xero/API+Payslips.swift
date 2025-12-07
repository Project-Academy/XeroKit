//
//  API+Payslips.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

extension Payslip {
    
    /**
     Retrieve a Payslip given the ID 
     
     This modifier can be used to set common headers like `Authorization` or custom headers.
     The header is stored internally and applied to the `urlRequest` when `build()` is called.
     
     - Parameters:
       - id: The PayslipId you wish to fetch from the Xero API.
     - Returns: A Xero Payslip object corresponding to the payslip ID.
     */
    public static func with(id: String) async throws -> Payslip {
        let response = try await API.Payslips.with(id).GET
            .response()
            
        var slip = try response
            .asType(PayslipsResponse.self)
            .slip
        
        let _ratesArray: [EarningsRate_Template]
        if let data = UserDefaults.standard.data(forKey: "XEROKIT_EARNINGS_RATES_LIST"),
           let ratesList = try? JSONDecoder().decode([EarningsRate_Template].self, from: data) {
            _ratesArray = ratesList
        } else { _ratesArray = try await EarningsRate_Template.list() }
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

struct PayslipsResponse: Decodable, XeroV1Response {
    
    let slip: Payslip
    
    // Default Response Variables
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
