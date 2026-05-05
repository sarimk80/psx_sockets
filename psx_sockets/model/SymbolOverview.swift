//
//  SymbolOverview.swift
//  psx_sockets
//
//  Created by sarim khan on 30/01/2026.
//

import Foundation

enum CompanyOverviews {
    case CompanyDetail
    case CompanyFinancials
}

enum ChartSelector{ 
    case Annual
    case Quaterly
}

enum ChartTimeFrame : String,CaseIterable,Identifiable{
    case M1 = "1m"
    case M5 = "5m"
    case M15 = "15m"
    case H1 = "1h"
    case H4 = "4h"
    case D1 = "1d"
    
    var id: String { rawValue }
}


struct SymbolOverview : Codable {
    let announcements: [Announcement]
    let financials: Financials
    let ratios: [Ratio]
    let timestamp: String
}

struct Announcement : Codable,Hashable,Identifiable{
    
    let date, title, documentLink, pdfLink: String
    
    var id: String { pdfLink }
    
    
}

struct Financials : Codable{
    let annual, quarterly: [Annual]
}

struct Annual : Codable{
    let period: String?
    let sales: Int?
    let profitAfterTax: Int?
    let eps: Double?
}

struct Ratio : Codable{
    let period: String?
    let grossProfitMargin: Double?
    let netProfitMargin, epsGrowth, peg: Double?
}
