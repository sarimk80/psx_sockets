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
    var singleTicker : PortfolioModel?
    
    init() {
        getSavedTicker()
    }
    
    private func getSavedTicker(){
        savedTicker = swiftDataService.getSavedTicker()

    }
    
    func addTicker(ticker:String,volume:Int,data:String,price:Double)  {
        swiftDataService.addTicker(ticker: ticker,volume: volume,date: data,price: price)
    }
    
    func addTransaction(portfolio:PortfolioModel,volume:Int,date:String,price:Double){
        swiftDataService.addTransaction(portfolio: portfolio, volume: volume, date: date,price: price)
        //getSavedTicker()
    }
    
    func deletePortfolio(ticker:String){
        swiftDataService.deleteTicker(ticker: ticker)
        //getSavedTicker()
    }
    
    func getSingleTicker(ticker:String){
       singleTicker = swiftDataService.getSingleTicker(ticker: ticker)
    }
    
    
}
