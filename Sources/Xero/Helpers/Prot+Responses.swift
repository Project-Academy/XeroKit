//
//  Prot+Responses.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

/**
 ```swift
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
 }
 ```
 */
public protocol XeroV1Response: Decodable {
    var id: String { get }
    var source: String { get }
    var status: String { get }
}




/**
 ```swift
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
 }
 ```
 */
public protocol XeroV2Response: Decodable {
    var id: String { get }
    var source: String { get }
    var status: String { get }
}

