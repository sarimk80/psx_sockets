//
//  SectorPsxResponse.swift
//  psx_sockets
//
//  Created by sarim khan on 08/01/2026.
//

import Foundation

struct SectorPsxResponse:Codable,Hashable{
    let sectors: [String:[SectorStocks]]
}

struct SectorStocks:Codable,Hashable,Identifiable {
    let scriptCode: String
    let scriptName: String
    let ldcp: String
    let open: String
    let high: String
    let low: String
    let current: String
    let change: String
    let volume: String
    let trend: String
        
    var id: String { scriptName }
    
    enum CodingKeys: String, CodingKey {
            case scriptCode = "script_code"
            case scriptName = "script_name"
            case ldcp
            case open
            case high
            case low
            case current
            case change
            case volume
            case trend
        }
}
