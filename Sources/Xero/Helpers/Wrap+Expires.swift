//
//  Wrap+Expires.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 24/11/2025.
//

import Foundation

/**
 A property wrapper arround a value that can expire.
 Getting the value after given duration or expiration date will return nil.
 
 Usage:
 ```swift
 @Expires(in: .seconds(60))
 var token: String?

 // New values will be valid for 60s
 token = "my-api-token"
 print(token) // "my-api-token"
 try await Task.sleep(61)
 print(token) // nil
```
 
 You can also update the value (and set either a new expiry date, or expiry duration):
 ```swift
 _token.update("new-api-token", expiry: Date.now.addingTimeInterval(1800))
 // OR
 _token.update("new-api-token", expiresIn: .seconds(1800))
 ```
 
 Setting the `wrappedValue` directly is fine, and will re-use the previous value for duration to calculate
 the new expiry date.
*/
@propertyWrapper @MainActor
public struct Expires<Value> {
    
    public var isValid: Bool { return (storedValue?.expiry ?? .now) > .now }
    
    public var wrappedValue: Value? {
        get { isValid ? storedValue?.value : nil }
        set {
            // Store the newValue, as well as
            // update the expiry
            storedValue = newValue.map { v in
                let newExpiry = Date.now.addingTimeInterval(duration.seconds)
                return (value: v, expiry: newExpiry)
            }
        }
    }
    private var storedValue: (value: Value?, expiry: Date)?
    private var duration: Duration
    
    
//    public var projectedValue: Self {
//        get { self }
//        set { self = newValue }
//    }
    
    //--------------------------------------
    // MARK: - INITIALISERS -
    //--------------------------------------
    public init(wrappedValue: Value? = nil, in time: Duration) {
        duration = time
        storedValue = (
            value: wrappedValue,
            expiry: .now.addingTimeInterval(time.seconds)
        )
    }
    
    //--------------------------------------
    // MARK: - UPDATE -
    //--------------------------------------
    public mutating func update(_ newValue: Value, expiry newExpiry: Date) {
        storedValue = (value: newValue, expiry: newExpiry)
    }
    public mutating func update(_ newValue: Value, expiresIn: Duration) {
        duration = expiresIn
        wrappedValue = newValue
    }
}
extension Expires: @MainActor CustomStringConvertible {
    public var description: String {
        guard let storedValue, let value = storedValue.value
        else { return "<ValueExpired>" }
        let df = DateFormatter()
        df.dateFormat = "h:mm a d/M/yyyy"
        let expiry = df.string(from: storedValue.expiry)
        return "\(String(describing: value)), expiringAt: \(expiry)"
    }
}

extension Duration {
    public var seconds: TimeInterval {
        return TimeInterval(components.seconds)
    }
}
