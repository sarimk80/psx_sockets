//
//  TickerPriceModel.swift
//  psx_sockets
//
//  Created by sarim khan on 03/03/2026.
//

import Foundation

struct TickerPriceModel:Codable {
    let status: Int
        let message: String
        let data: [TickerPriceData]
}

struct TickerPriceData: Codable {
    let date: Int
    let price: Double
    let volume: Int
}
