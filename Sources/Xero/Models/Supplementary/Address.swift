//
//  Address.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 13/11/2025.
//

import Foundation

public struct Address: Codable {
    /// Address line 1 for employee home address
    public var addressLine1:    String
    /// Address line 2 for employee home address
    public var addressLine2:    String?
    /// Suburb for employee home address
    public var city:            String
    /// State abbreviation for employee home address
    public var state:           AusState
    /// Postcode for employee home address
    public var postCode:        String
    /// Country of HomeAddress
    public var country:         Country

    //--------------------------------------
    // MARK: - INIT -
    //--------------------------------------
    public init(
        addressLine1: String,
        addressLine2: String? = nil,
        city:         String,
        state:        AusState,
        postCode:     String,
        country:      Country
    ) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city         = city
        self.state        = state
        self.postCode     = postCode
        self.country      = country
    }

    //--------------------------------------
    // MARK: - CODING KEYS -
    //--------------------------------------
    enum CodingKeys: String, CodingKey {
        case addressLine1   = "AddressLine1"
        case addressLine2   = "AddressLine2"
        case city           = "City"
        case state          = "Region"
        case postCode       = "PostalCode"
        case country        = "Country"
    }
    
    //--------------------------------------
    // MARK: - SUPPLEMENTARY TYPES -
    //--------------------------------------
    public enum AusState: String, Codable {
        case ACT, NSW, NT, QLD, SA, TAS, VIC, WA
    }
    public enum Country: String, Codable {
        case australia = "AUSTRALIA"
    }
}
