//
//  AllSymbolsModel.swift
//  psx_sockets
//
//  Created by sarim khan on 28/08/2025.
//


import Foundation

struct AllSymbolsModel:Codable{
    let success: Bool
    let data: [String]
    let timestamp: Int
}
