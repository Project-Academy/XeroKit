//
//  Tapioca+Helpers.swift
//  XeroKit
//
//  Small convenience surfaces on Tapioca / Presto types that Xero's
//  endpoints repeat a lot:
//   - `Request.arrayWrappedJSONBody()` — replaces the
//     `paramTransformer { dict in JSONSerialization.data(withJSONObject:
//     [dict], …) }` boilerplate Xero requires for write endpoints.
//   - `Response.header(_:)` — case-insensitive header lookup.
//

import Foundation

extension Request {
    /**
     Wraps the request body in a single-element JSON array — the
     shape Xero requires for POST writes (`/Employees`, `/Payslip/<id>`,
     `/PayRuns`, etc.). Equivalent to writing
     `paramTransformer { try JSONSerialization.data(withJSONObject: [$0], options: .prettyPrinted) }`
     by hand each time.
     */
    public func arrayWrappedJSONBody() -> Self {
        paramTransformer { dict in
            try JSONSerialization.data(withJSONObject: [dict], options: .prettyPrinted)
        }
    }
}

extension Response {
    /**
     Case-insensitive lookup of a header value by name. Saves the
     `headers?[key] as? String` pattern. Returns nil when there's no
     HTTP response or no matching header.
     */
    public func header(_ name: String) -> String? {
        guard let headers else { return nil }
        for (key, value) in headers {
            if let key = key as? String,
               key.caseInsensitiveCompare(name) == .orderedSame {
                return value as? String
            }
        }
        return nil
    }
}
