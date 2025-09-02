//
//  psxCompaniesModel.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation

struct PsxCompaniesModel: Codable {
    let success: Bool
    let data: DataClassCompanies
    let timestamp: Int
}

// MARK: - DataClassCompanies
struct DataClassCompanies: Codable {
    let symbol, scrapedAt: String
    let financialStats: FinancialStats
    let businessDescription: String
    let keyPeople: [KeyPerson]
}

// MARK: - FinancialStats
struct FinancialStats: Codable {
    let marketCap, shares, freeFloat, freeFloatPercent: FreeFloat
}

// MARK: - FreeFloat
struct FreeFloat: Codable {
    let raw: String
    let numeric: Double
}

// MARK: - KeyPerson
struct KeyPerson: Codable {
    let name, position: String
}


