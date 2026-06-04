//
//  CurrencyExchangeModel.swift
//  psx_sockets
//
//  Created by sarim khan on 04/06/2026.
//

import Foundation

// MARK: - CurrencyExchangeModel
struct CurrencyExchangeModel: Codable {
    let response: [CurrencyResponse]
}

// MARK: - Response
struct CurrencyResponse: Codable {
    let country: String
    let currency: Double
    let currencyName: String
    let type: String
}

enum CurrencyFilter:String,CaseIterable,Codable {
    case All
    case Asia
    case Crypto
    case MiddleEast = "Middle East"
    case Europe
    case Americas
    case Africa
    case Oceania
    case Other
}
