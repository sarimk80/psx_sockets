//
//  MetalModel.swift
//  psx_sockets
//
//  Created by sarim khan on 10/07/2026.
//

import Foundation


struct MetalModel: Codable {
    
    var date: String
    var close: Double
    var high: Double
    var low: Double
    var open: Double
    var volume: Int
    
    var id: String {date}
    
    var parsedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: date)
    }
    
}

extension MetalModel {
    static let mock = MetalModel(date: "2025-08-04T00:00:00", close: 0.0, high: 0.0, low: 0.0, open: 0.0, volume: 12)
}


enum ChartRange: String,CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "All"
}
