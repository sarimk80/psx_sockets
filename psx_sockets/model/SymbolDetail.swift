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
struct SymbolDataClass: Codable,Hashable,Identifiable {
    let market, st, symbol: String
    let price, change, changePercent: Double
    let volume, trades: Int
    let value, high, low, bid, ask: Double
    let  bidVol, askVol: Int
    let timestamp: Int
    let sectorName:String?
    let portfolioVolume:Int?
    let fullName:String?
    let circuit_breaker:String//": "14.81 — 18.10",
    let day_range:String//": "16.29 — 16.45",
    let week_range_52:String//": "12.50 — 20.83",
    let ldcp:Double//": 16.48,
    let haircut:Double//": 17.5,
    let price_earning:Double//": 0,
    let year_1_change:Double//": 0,
    let ytd_change:Double//": 0
    let market_cap:Double?//": 31339676.52,
    let shares:Int?//": 908923333,
    let free_float:Double?//": 227230833,
    let free_float_share:Double?//": 25,
    let key_people: [StockKeyPeople]?
    let business_description:String
    let dividend:[StockDividend]?
    
    var id:String { symbol }
    
}

struct StockKeyPeople:Codable,Hashable,Identifiable {
    let position:String//": "CEO",
    let person:String//": "Abdul Qayoom
    
    var id:String {person}
    
}

struct StockDividend: Codable,Hashable,Identifiable{
    let announcement_date:String?//": "2026-03-31T16:32:00",
    let period_end:String?//": null,
    let period:String?//": null,
    let percentage:Double?//": 6.6,
    let installment:String?//": "Second",
    let type:String?//": "Dividend",
    let book_closure_start:String?//": "2026-04-10",
    let book_closure_end:String?//": "2026-04-12"
    
    var id: String {
        "\(announcement_date ?? "")-\(period_end ?? "")-\(installment ?? "")"
    }
}


extension SymbolDataClass {
    static let mock = SymbolDataClass(market: "", st: "", symbol: "", price: 0.0, change: 0.8, changePercent: 0.0, volume: 0, trades: 0, value: 0.0, high: 0.0, low: 0.0, bid: 0.0, ask: 0.0, bidVol: 0, askVol: 0, timestamp: 0, sectorName: "", portfolioVolume: 0,fullName: "",circuit_breaker: "",day_range: "",week_range_52: "",ldcp: 0.0,haircut: 0.0,
        price_earning: 0.0,year_1_change: 0.0,ytd_change: 0.0,market_cap: 0.0,shares: 123,free_float:
        0.0,free_float_share: 0.0,key_people: [StockKeyPeople(position: "", person: "")],business_description: "",dividend: [])
}

