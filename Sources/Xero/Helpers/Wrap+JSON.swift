//
//  Wrap+JSON.swift
//  XeroKit
//
//  `Encodable.json` — converts any `Encodable` value to the
//  `[String: any Sendable]` dictionary shape that `Request.params(_:)`
//  expects. Used by the create / update POST endpoints (Employee,
//  Payslip, etc.) to build the request body from a model instance.
//
//  Internal to XeroKit so we don't pollute every `Encodable` with a
//  `.json` property in consumer code.
//

import Foundation

internal extension Encodable {
    /**
     Encodes this value to JSON via `JSONEncoder` and reads it back as
     a `[String: any Sendable]` dictionary. Returns nil if the
     `Encodable` doesn't serialise to a top-level JSON object (e.g.
     an array or primitive).

     - Note: The `as!` cast to `[String: any Sendable]` is safe because
       `JSONSerialization` only ever produces `String`, `NSNumber`,
       `NSNull`, `NSArray`, and `NSDictionary` values — all effectively
       immutable + Sendable. `Sendable` is a marker protocol so the
       cast is informational rather than checked.
     */
    var json: [String: any Sendable]? {
        guard let data = try? JSONEncoder().encode(self),
              let obj  = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let dict = obj as? [String: Any]
        else { return nil }
        return dict.mapValues { $0 as! any Sendable }
    }
}
