//
//  PsxDivideneModel.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation

    // MARK: - PsxDividendModel
    struct PsxDividendModel: Codable {
        let success: Bool
        let data: [Datum]
        let count: Int
        let symbol: String
        let timestamp: Int
        let cacheUpdated: String
    }

    // MARK: - Datum
    struct Datum: Codable,Identifiable {
        let symbol, exDate, paymentDate, recordDate: String
        let amount: Double
        let year: Int
        
        var id:String {paymentDate}

        enum CodingKeys: String, CodingKey {
            case symbol
            case exDate = "ex_date"
            case paymentDate = "payment_date"
            case recordDate = "record_date"
            case amount, year
        }
    }


