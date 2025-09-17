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
    
    init( ticker: String, isSelected: Bool) {
        self.ticker = ticker
        self.isSelected = isSelected
    }
}
