// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let kLineRequestModel = try? JSONDecoder().decode(KLineRequestModel.self, from: jsonData)

import Foundation

// MARK: - KLineRequestModel
struct KLineRequestModel: Codable {
    let success: Bool
    let data: [KLineDatum]
    let count: Int
    let symbol: String
    let timeframe: String
    let appliedLimit, timestamp: Int
}

// MARK: - Datum
struct KLineDatum: Codable,Identifiable {
    let symbol: String
    let timeframe: String
    let timestamp: Int
    let datumOpen, high, low, close: Double
    let volume: Int
    
    var id: String {String(timestamp)}
    
    var customDate: Date{ Date(timeIntervalSince1970: (Double(timestamp)/1000) ) }
    
    var adjustedDate: Date {
            let calendar = Calendar.current
            let date = customDate
            
            switch timeframe {
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
        case symbol, timeframe, timestamp
        case datumOpen = "open"
        case high, low, close, volume
    }
}

