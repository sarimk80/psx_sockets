//
//  SymbolDetail.swift
//  psx_sockets
//
//  Created by sarim khan on 03/09/2025.
//

import Foundation

// MARK: - SymbolDetail
struct SymbolDetail: Codable {
    let success: Bool
    let data: SymbolDataClass
    let timestamp: Int
}

// MARK: - DataClass
struct SymbolDataClass: Codable {
    let market, st, symbol: String
    let price, change, changePercent: Double
    let volume, trades: Int
    let value, high, low, bid, ask: Double
    let  bidVol, askVol: Int
    let timestamp: Int
    let sectorName:String?
    let portfolioVolume:Int?
}


extension SymbolDataClass {
    static let mock = SymbolDataClass(market: "", st: "", symbol: "", price: 0.0, change: 0.8, changePercent: 0.0, volume: 0, trades: 0, value: 0.0, high: 0.0, low: 0.0, bid: 0.0, ask: 0.0, bidVol: 0, askVol: 0, timestamp: 0, sectorName: "", portfolioVolume: 0)
}

