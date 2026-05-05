//
//  EtfModel.swift
//  psx_sockets
//
//  Created by sarim khan on 04/05/2026.
//

import Foundation


struct EtfModel: Codable {
    let etfs: [Etf]
}

// MARK: - Etf
struct Etf: Codable,Hashable,Identifiable {
    let id: String
    let etfName, fullName, description: String
    let fundSize, marketCap, noOfShares: String
    let keyPeople: [EtfKeyPerson]
    let symbols: [Symbol]
    let type: String
}

// MARK: - KeyPerson
struct EtfKeyPerson: Codable,Hashable {
    let position: Position
    let person: String
}

enum Position: String, Codable {
    case ceo = "CEO"
    case chairman = "Chairman"
    case chiefExecutiveOfficer = "Chief Executive Officer"
    case companySecretary = "Company Secretary"
}

// MARK: - Symbol
struct Symbol: Codable,Hashable {
    let company, ticker: String
    let weight: Double
}
