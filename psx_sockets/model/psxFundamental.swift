//
//  psxFundamental.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation


    
    // MARK: - PsxFundamentalsModel
    struct PsxFundamentalsModel: Codable {
        let success: Bool
        let data: FundamentalDataClass
        let timestamp: Int
    }

    // MARK: - DataClass
    struct FundamentalDataClass: Codable {
        let symbol, sector, listedIn, marketCap: String
        let price, changePercent, yearChange, peRatio: Double
        let dividendYield: Double
        let freeFloat: String
        let volume30Avg: Double
        let isNonCompliant: Bool
        let timestamp: String
    }

