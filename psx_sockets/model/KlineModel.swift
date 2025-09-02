//
//  KlineModel.swift
//  psx_sockets
//
//  Created by sarim khan on 01/09/2025.
//

import Foundation

// MARK: - KlineModel
struct KlineModel: Codable {
    let type, symbol, timeframe: String
    let klines: [KlineDataModel]
    let timestamp: Int
}

// MARK: - Datum
struct KlineDataModel: Codable,Identifiable {
    let symbol, market: String
    let timestamp: Int
    let interval: String
    let datumOpen: Double
    let high: Double
    let low, close: Double
    let quoteVolume: Double
    let volume, trades: Int
    
    var id: String {String(timestamp)}
    
    var customDate: Date{ Date(timeIntervalSince1970: (Double(timestamp)/1000) ) }

    enum CodingKeys: String, CodingKey {
        case symbol, market, timestamp, interval
        case datumOpen = "open"
        case high, low, close, volume, quoteVolume, trades
    }
}
