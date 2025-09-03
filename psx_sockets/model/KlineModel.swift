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
    
    var domainLength:TimeInterval {
        switch timeframe {
            case "1m":  return 60 * 60        // show 1 hour worth of 1m candles
            case "5m":  return 60 * 60 * 6    // 6 hours
            case "15m": return 60 * 60 * 24   // 1 day
            case "1h":  return 60 * 60 * 24 * 7   // 1 week
            case "4h":  return 60 * 60 * 24 * 30  // 1 month
            case "1d":  return 60 * 60 * 24 * 90  // 3 months
            default:    return 60 * 60 * 24       // fallback = 1 day
            }
    }
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
    
    var adjustedDate: Date {
            let calendar = Calendar.current
            let date = customDate
            
            switch interval {
            case "1m":
                return calendar.date(bySetting: .second, value: 0, of: date) ?? date
            case "5m":
                let minute = calendar.component(.minute, from: date)
                let rounded = (minute / 5) * 5
                return calendar.date(bySetting: .minute, value: rounded, of: date) ?? date
            case "15m":
                let minute = calendar.component(.minute, from: date)
                let rounded = (minute / 15) * 15
                return calendar.date(bySetting: .minute, value: rounded, of: date) ?? date
            case "1h":
                return calendar.date(bySetting: .minute, value: 0, of: date) ?? date
            case "4h":
                let hour = calendar.component(.hour, from: date)
                let rounded = (hour / 4) * 4
                return calendar.date(bySetting: .hour, value: rounded, of: date) ?? date
            case "1d":
                return calendar.startOfDay(for: date)
            default:
                return date
            }
        }
    

    enum CodingKeys: String, CodingKey {
        case symbol, market, timestamp, interval
        case datumOpen = "open"
        case high, low, close, volume, quoteVolume, trades
    }
}
