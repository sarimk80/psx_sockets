//
//  CircuitBreakerModel.swift
//  psx_sockets
//
//  Created by sarim khan on 20/05/2026.
//

import Foundation

struct CircuitBreakerModel: Codable {
    let upper, lower: [Lower]
}

// MARK: - Lower
struct Lower: Codable,Identifiable {
    let symbol: String
    let ldcp, lowerOpen, high, low: Double
    let current, change, changePercent: Double
    let volume: Int
    
    var id : String{symbol}

    enum CodingKeys: String, CodingKey {
        case symbol, ldcp
        case lowerOpen = "open"
        case high, low, current, change
        case changePercent = "change_percent"
        case volume
    }
}

