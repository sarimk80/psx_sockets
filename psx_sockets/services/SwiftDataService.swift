//
//  SwiftDataService.swift
//  psx_sockets
//
//  Created by sarim khan on 19/09/2025.
//

import Foundation
import SwiftData

class SwiftDataService{
    
    var modelContext: ModelContext? = nil
    var modelContainer: ModelContainer? = nil
    
    init() {
        do {
            // container init
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: PortfolioModel.self, configurations: configuration)
            modelContainer = container
            // get model context
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
                    
            // query data
            // more to come

            } catch(let error) {
                print(error)
                print(error.localizedDescription)
            }
    }
    
     func getSavedTicker() -> [PortfolioModel]{
        guard let modelContext = modelContext else {
                return []
            }
        let todoDescriptor = FetchDescriptor<PortfolioModel>(
            predicate: #Predicate {$0.isSelected}
        )
        do {
            return  try modelContext.fetch(todoDescriptor)
            } catch(let error) {
                //self.error = error
                print(error.localizedDescription)
                return []
            }
         
    }
    
    func addTicker(ticker:String,volume:Int,date:String,price:Double)  {
        guard let modelContext = modelContext else {
                return
            }
       
        let portfolioModel = PortfolioModel(ticker: ticker, isSelected: true,volume: volume)
        
        let transaction = Transaction(ticker: ticker, volume: volume, date: date, portfolio: portfolioModel,price: price)
        
        portfolioModel.transaction.append(transaction)
        
        modelContext.insert(portfolioModel)
        
        saveData()
        
        }
    
    func deleteTicker(ticker: String) {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<PortfolioModel>(
            predicate: #Predicate { $0.ticker == ticker }
        )

        if let portfolio = try? modelContext.fetch(descriptor).first {
            modelContext.delete(portfolio)
            saveData()
        }
    }
    
    func addTransaction(portfolio:PortfolioModel,volume:Int,date:String,price:Double){
        guard let modelContext = modelContext else {
                return
            }
        
        let transaction = Transaction(ticker: portfolio.ticker, volume: volume, date: date,portfolio: portfolio,price: price)
        
        modelContext.insert(transaction)
        
        saveData()
        
    }
    
    func getSingleTicker(ticker:String) -> PortfolioModel? {
        
        guard let modelContext = modelContext else { return nil}
        
        let descriptor = FetchDescriptor<PortfolioModel>(
            predicate: #Predicate { $0.ticker == ticker }
        )
        
        return try? modelContext.fetch(descriptor).first
        
    }
    
    func saveData()  {
        guard let modelContext = modelContext else {
                return
            }
        do{
          try  modelContext.save()
        }
        catch(let error){
            print(error.localizedDescription)
        }
    }
    
    func clearAllData(){
        guard let modelContext = modelContext else {
                return
            }
        do{
            try modelContext.delete(model: PortfolioModel.self)
            saveData()


        }catch(let error){
            print(error.localizedDescription)
        }
    }
    
}
