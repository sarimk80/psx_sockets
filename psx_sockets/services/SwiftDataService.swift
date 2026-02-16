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
    
    func addTicker(ticker:String,volume:Int)  {
        guard let modelContext = modelContext else {
                return
            }
       if let filterTicker = getSavedTicker().first(where: {$0.ticker == ticker}){
           modelContext.delete(filterTicker)
        }else{
            let portfolioModel = PortfolioModel(ticker: ticker, isSelected: true,volume: volume)
            modelContext.insert(portfolioModel)

        }
        saveData()
        
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
    
}
