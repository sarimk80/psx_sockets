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
