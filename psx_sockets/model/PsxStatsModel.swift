//
//  PsxStatsModel.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation

struct PsxStatsModel:Codable{
    let success: Bool
    let data: DataClass
    let timestamp: Int
}

struct DataClass:Codable{
    let totalVolume: Int
    let totalValue: Double
    let totalTrades, symbolCount, gainers, losers: Int
    let unchanged: Int
    let topGainers, topLosers: [Top]
}

struct Top:Codable{
    let symbol: String
    let change, changePercent, price: Double
    let volume: Int
    let value: Double
}
