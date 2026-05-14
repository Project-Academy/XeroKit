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

     - Note: The `as!` cast triggers Swift compiler warning "Forced cast
       from 'Any' to 'any Sendable' always succeeds; did you mean to use
       'as'?" — that suggestion is wrong: `Sendable` is a marker protocol
       and Swift forbids it in `as` / `as?` conditional casts. The
       warning is a known compiler bug (swiftlang/swift#86650). The cast
       itself is safe — `JSONSerialization` only ever returns `String`,
       `NSNumber`, `NSNull`, `NSArray`, or `NSDictionary`, all of which
       are immutable + Sendable in practice.
     */
    var json: [String: any Sendable]? {
        guard let data = try? JSONEncoder().encode(self),
              let obj  = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let dict = obj as? [String: Any]
        else { return nil }
        return dict.mapValues { $0 as! any Sendable }
    }
}
