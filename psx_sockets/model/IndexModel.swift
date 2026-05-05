//
//  IndexModel.swift
//  psx_sockets
//
//  Created by sarim khan on 04/05/2026.
//

import Foundation

struct IndexModel: Codable {
    let success: Bool
    let data: IndexDataClass
    let timestamp: Int
}

// MARK: - DataClass
struct IndexDataClass: Codable {
    let market: String
    let st: String
    let symbol: String
    let price, change, changePercent: Double
    let volume, trades, value, dataOpen: Int
    let high, low: Double
    let bid, ask: Int
    let circuitBreaker, dayRange, weekRange52: String
    let bidVol, askVol, timestamp: Int
    let ldcp: Double
    let dataVar, haircut, priceEarning: Int
    let year1_Change, ytdChange: Double

    enum CodingKeys: String, CodingKey {
        case market, st, symbol, price, change, changePercent, volume, trades, value
        case dataOpen = "open"
        case high, low, bid, ask
        case circuitBreaker = "circuit_breaker"
        case dayRange = "day_range"
        case weekRange52 = "week_range_52"
        case bidVol, askVol, timestamp, ldcp
        case dataVar = "var"
        case haircut
        case priceEarning = "price_earning"
        case year1_Change = "year_1_change"
        case ytdChange = "ytd_change"
    }
}
