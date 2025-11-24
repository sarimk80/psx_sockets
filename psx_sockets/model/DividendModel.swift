//
//  DividendModel.swift
//  psx_sockets
//
//  Created by sarim khan on 24/11/2025.
//

import SwiftUI

enum CorporationEnum: String{
    case Dividend
    case Eps
    case ProfitLoss
    case Meeting
}

struct DividendModel: Codable, Hashable,Identifiable {
    let company, dividend, date, boardMeeting: String
    let eps, profitLossBeforeTax, profitLossAfterTax: String
    let yearEnded: String
    let id = UUID()

    enum CodingKeys: String, CodingKey {
        case company = "Company"
        case dividend = "Dividend"
        case date = "Date"
        case boardMeeting = "BoardMeeting"
        case eps = "Eps"
        case profitLossBeforeTax, profitLossAfterTax, yearEnded
    }
}
