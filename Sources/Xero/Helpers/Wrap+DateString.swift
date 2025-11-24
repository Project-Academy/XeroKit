//
//  Wrap+DateString.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 13/11/2025.
//

import Foundation

@propertyWrapper
public struct DateString: Codable, Equatable, CustomStringConvertible {
    
    // Store the original raw string
    private var _rawString: String?
    public var wrappedValue: Date?
    
    
    var value: String? {
        set {
            _rawString = newValue
            wrappedValue = Date(newValue)
        }
        get {
            if let _rawString { return _rawString }
            
            // Normalize the date so that only the calendar day is used.
            guard let date = wrappedValue?.APINormalized
            else { return nil }
            let unixMillis = UnixTimestamp(date.timeIntervalSince1970 * 1000)
            
            // Returns the full format, which is often required for API POST/PUT requests
            return "/Date(\(unixMillis)+0000)/"
        }
    }
    
    // Add a projectedValue so you can access the string representation externally
    public var projectedValue: String? { value }
    
    //--------------------------------------
    // MARK: - CODABLE -
    //--------------------------------------
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(String?.self)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    //--------------------------------------
    // MARK: - DESCRIPTION -
    //--------------------------------------
    public var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        if let date = wrappedValue {
            return dateFormatter.string(from: date)
        } else { return "No Date" }
    }
}

//--------------------------------------
// MARK: - UNIX -
//--------------------------------------
typealias UnixTimestamp = Int
extension Date {
    /// Date to Unix timestamp.
    var unix: UnixTimestamp {
        UnixTimestamp(self.timeIntervalSince1970)
    }
}

//--------------------------------------
// MARK: - NORMALIZED DATE -
//--------------------------------------
extension Date {
    /**
     - Returns: a new Date that represents the same calendar day as `self`,
     using the device’s local time zone for component extraction,
     but normalized to midnight in UTC.
     */
    var APINormalized: Date {
        let calendar = Calendar(identifier: .gregorian)
        
        // Extract the components in the local time zone.
        let local = calendar.dateComponents(in: TimeZone.current, from: self)
        
        // Now create a new date from those components in UTC.
        var utcCalendar = calendar
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        // We only care about year, month, and day.
        let components = DateComponents(year: local.year, month: local.month, day: local.day)
        return utcCalendar.date(from: components) ?? self
    }
}


//--------------------------------------
// MARK: - DATE INITIALISER -
//--------------------------------------
fileprivate extension Date {
    
    /**
     Initialize from an API date string in the format "/Date(milliseconds)/" or "/Date(milliseconds+offset)/"
     
     This handles the following variations:
     1. "/Date(1762416733219)/"
     2. "/Date(1167177600000+0000)/"
     */
    init?(_ dateString: String?) {
        guard let dateString else { return nil }
        
        // Ensure the string has the correct API wrapper format
        guard dateString.hasPrefix("/Date(") && dateString.hasSuffix(")/")
        else { return nil }
        
        // Extract the inner content (e.g., "1762416733219" or "1167177600000+0000")
        let startIndex = dateString.index(dateString.startIndex, offsetBy: 6) // Skips "/Date("
        let endIndex = dateString.index(dateString.endIndex, offsetBy: -2) // Skips ")/"
        let content = dateString[startIndex..<endIndex]
        
        // Find the timezone offset separator (+ or -).
        let separatorIndex = content.firstIndex(where: { $0 == "+" || $0 == "-" })
        
        let millisString: Substring
        if let separatorIndex {
            // If separator exists, use only the millisecond part before it
            millisString = content[..<separatorIndex]
        } else {
            // If no separator exists, use the entire content (this handles the first format)
            millisString = content
        }
        
        // Convert to Double and initialize Date
        guard let milliseconds = Double(millisString)
        else { return nil }
        
        let seconds = milliseconds / 1000.0
        self.init(timeIntervalSince1970: seconds)
    }
}

//--------------------------------------
// MARK: - HANDLE NIL KEYS -
//--------------------------------------
extension KeyedDecodingContainer {
  func decode(_ type: DateString.Type, forKey key: Key) throws -> DateString {
      try decodeIfPresent(type, forKey: key) ?? .init(wrappedValue: nil)
  }
}
