//
//  PortfolioModel.swift
//  psx_sockets
//
//  Created by sarim khan on 16/09/2025.
//

import Foundation
import SwiftData

@Model
class PortfolioModel{
    @Attribute(.unique) var id: UUID = UUID()
    var ticker:String
    var isSelected:Bool
    var volume:Int?
    
    init( ticker: String, isSelected: Bool,volume:Int) {
        self.ticker = ticker
        self.isSelected = isSelected
        self.volume = volume
    }
}
