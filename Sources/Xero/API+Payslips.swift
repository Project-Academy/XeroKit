//
//  API+Payslips.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

extension Payslip {
    
    public static func with(id: String) async throws -> Payslip {
        let response = try await API.Payslips.with(id).GET
            .response()
            
        let slip = try response
            .asType(PayslipsResponse.self)
            .slip
        
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
