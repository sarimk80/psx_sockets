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


// MARK: - SectorModel
struct SectorModel: Codable {
    let success: Bool
    let data: [String:SectorDataModel]
    let timestamp: Int
}

// MARK: - Datum
struct SectorDataModel: Codable,Hashable,Identifiable {
    let totalVolume: Int
    let totalValue: Double
    let totalTrades, gainers, losers: Int
    let avgChange, avgChangePercent,unchanged: Double
    let symbols: [String]
    
    var id:String {symbols.first ?? ""}
}

extension SectorDataModel{
    static let mock = SectorDataModel(totalVolume: 0, totalValue: 0.0, totalTrades: 0, gainers: 0, losers: 0, avgChange: 0.0, avgChangePercent: 0.0, unchanged: 0.0, symbols: [])
}
