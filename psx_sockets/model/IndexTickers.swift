//
//  IndexTickers.swift
//  psx_sockets
//
//  Created by sarim khan on 04/08/2026.
//

import Foundation


enum IndexFilterEnums: String, Identifiable, CaseIterable {
    case Current
    case High
    case Low
    case IndexWeight
    case Volume
    case MarketCap
    
    var id: Self { self }
}

struct IndexTickers: Codable {
    var symbol: String
    let name, ldcp, current: String
    let change, idxWeight: Double
    let volume: String
    let freeFloat, marketCap: Int

    enum CodingKeys: String, CodingKey {
        case symbol, name, ldcp, current, change
        case idxWeight = "idx_weight"
        case volume, freeFloat, marketCap
    }
}
