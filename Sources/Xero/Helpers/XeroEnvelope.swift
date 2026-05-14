//
//  XeroEnvelope.swift
//  XeroKit
//
//  Generic decoders for Xero's two response envelope shapes. Each
//  endpoint family declares a tiny `XeroResponseKey` carrier (one
//  static string for the JSON key under which its resource lives)
//  and then aliases its response type as `XeroV1Envelope<Resource, Key>`.
//
//  V1 envelope (`1.0/*` endpoints — Employees, Payslip, PayRuns,
//  SuperFunds): `{Id, ProviderName, Status, DateTimeUTC, <Resource>}`
//
//  V2 envelope (`2.0/*` endpoints — earningsRates): `{id, providerName,
//  httpStatusCode, dateTimeUTC, pagination?, <resource>}`
//

import Foundation

/// Phantom-type key carrier used to thread the JSON resource key
/// through `XeroV*Envelope`'s generic parameter list.
public protocol XeroResponseKey {
    /// The JSON key under which the wrapped resource lives in the
    /// response envelope (e.g. `"Employees"`, `"PayRuns"`, `"Payslip"`).
    static var jsonKey: String { get }
}

//--------------------------------------
// MARK: - V1 -
//--------------------------------------
public struct XeroV1Envelope<Resource: Decodable, Key: XeroResponseKey>: Decodable {
    public let id: String
    public let source: String
    public let status: String
    public let utcDate: Date?
    public let resource: Resource

    private enum EnvelopeKey: String, CodingKey {
        case id = "Id"
        case source = "ProviderName"
        case status = "Status"
        case utcDate = "DateTimeUTC"
    }

    public init(from decoder: Decoder) throws {
        let env = try decoder.container(keyedBy: EnvelopeKey.self)
        self.id     = try env.decode(String.self, forKey: .id)
        self.source = try env.decode(String.self, forKey: .source)
        self.status = try env.decode(String.self, forKey: .status)
        self.utcDate = try env.decodeIfPresent(DateString.self, forKey: .utcDate)?.wrappedValue
        let res = try decoder.container(keyedBy: DynamicResourceKey.self)
        self.resource = try res.decode(Resource.self, forKey: DynamicResourceKey(Key.jsonKey))
    }
}

//--------------------------------------
// MARK: - V2 -
//--------------------------------------
public struct XeroV2Envelope<Resource: Decodable, Key: XeroResponseKey>: Decodable {
    public let id: String
    public let source: String
    public let status: String
    public let utcDate: Date?
    public let pagination: [String: Int]?
    public let resource: Resource

    private enum EnvelopeKey: String, CodingKey {
        case id
        case source = "providerName"
        case status = "httpStatusCode"
        case utcDate = "dateTimeUTC"
        case pagination
    }

    public init(from decoder: Decoder) throws {
        let env = try decoder.container(keyedBy: EnvelopeKey.self)
        self.id         = try env.decode(String.self, forKey: .id)
        self.source     = try env.decode(String.self, forKey: .source)
        self.status     = try env.decode(String.self, forKey: .status)
        self.utcDate    = try env.decodeIfPresent(DateString.self, forKey: .utcDate)?.wrappedValue
        self.pagination = try env.decodeIfPresent([String: Int].self, forKey: .pagination)
        let res = try decoder.container(keyedBy: DynamicResourceKey.self)
        self.resource = try res.decode(Resource.self, forKey: DynamicResourceKey(Key.jsonKey))
    }
}

//--------------------------------------
// MARK: - DYNAMIC KEY -
//--------------------------------------
/// A `CodingKey` whose `stringValue` is determined at runtime — lets
/// us look up the resource by `Key.jsonKey` regardless of generic
/// instantiation.
private struct DynamicResourceKey: CodingKey {
    let stringValue: String
    var intValue: Int? { nil }
    init(_ s: String) { stringValue = s }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}
