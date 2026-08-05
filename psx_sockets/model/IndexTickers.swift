//
//  IndexTickers.swift
//  psx_sockets
//
//  Created by sarim khan on 04/08/2026.
//

import Foundation


struct IndexTickers: Codable {
    let symbol, name, ldcp, current: String
    let change, idxWeight: Double
    let volume: String
    let freeFloat, marketCap: Int

    enum CodingKeys: String, CodingKey {
        case symbol, name, ldcp, current, change
        case idxWeight = "idx_weight"
        case volume, freeFloat, marketCap
    }
}
