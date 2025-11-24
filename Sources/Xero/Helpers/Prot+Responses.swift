//
//  Prot+Responses.swift
//  XeroKit
//
//  Created by Sarfraz Basha on 25/11/2025.
//

import Foundation

public protocol XeroV1Response: Decodable {
    var id: String { get }
    var source: String { get }
    var status: String { get }
}
