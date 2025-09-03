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
}


//{
//    "success": true,
//    "data": {
//        "market": "REG",
//        "st": "PCL",
//        "symbol": "DCR",
//        "price": 32.28,
//        "change": -0.17,
//        "changePercent": -0.00524,
//        "volume": 854510,
//        "trades": 1853,
//        "value": 27590476.87,
//        "high": 32.5,
//        "low": 32.2,
//        "bid": 32.28,
//        "ask": 32.28,
//        "bidVol": 348,
//        "askVol": 0,
//        "timestamp": 1756895871
//    },
//    "timestamp": 1756895956774
//}
