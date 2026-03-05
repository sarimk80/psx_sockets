//
//  PortfolioViewModel.swift
//  psx_sockets
//
//  Created by sarim khan on 16/09/2025.
//

import Foundation
import Combine
import SwiftData



@Observable
class PortfolioViewModel{
    
    var savedTicker:[PortfolioModel] = []
    private var swiftDataService:SwiftDataService = SwiftDataService()
    
    init() {
        getSavedTicker()
    }
    
    private func getSavedTicker(){
        savedTicker = swiftDataService.getSavedTicker()

    }
    
    func addTicker(ticker:String,volume:Int,data:String)  {
        swiftDataService.addTicker(ticker: ticker,volume: volume,date: data)
        //getSavedTicker()
    }
    
    func addTransaction(portfolio:PortfolioModel,volume:Int,date:String){
        swiftDataService.addTransaction(portfolio: portfolio, volume: volume, date: date)
        //getSavedTicker()
    }
    
    func deletePortfolio(ticker:String){
        swiftDataService.deleteTicker(ticker: ticker)
        //getSavedTicker()
    }
    
    
}
