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
    @Relationship(deleteRule: .cascade, inverse: \Transaction.portfolio)
    var transaction = [Transaction]()
    
    
    init( ticker: String, isSelected: Bool,volume:Int) {
        self.ticker = ticker
        self.isSelected = isSelected
        self.volume = volume
    }
}

@Model
class Transaction{
    @Attribute(.unique) var id: UUID = UUID()
    var ticker:String
    var volume:Int
    var date:String
    var price: Double?
    
    var portfolio: PortfolioModel?
    
    init(ticker: String, volume: Int, date: String,portfolio: PortfolioModel? = nil,price: Double? = 1) {
        self.ticker = ticker
        self.volume = volume
        self.date = date
        self.portfolio = portfolio
        self.price = price
    }
}
