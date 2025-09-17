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
            getSavedTicker()
            // more to come

            } catch(let error) {
                print(error)
                print(error.localizedDescription)
            }
    }
    
    private func getSavedTicker(){
        guard let modelContext = modelContext else {
                return
            }
        let todoDescriptor = FetchDescriptor<PortfolioModel>(
            predicate: #Predicate {$0.isSelected}
        )
        do {
            savedTicker = try modelContext.fetch(todoDescriptor)
            } catch(let error) {
                //self.error = error
                print(error.localizedDescription)
            }
    }
    
    func addTicker(ticker:String)  {
        guard let modelContext = modelContext else {
                return
            }
       if let filterTicker = savedTicker.first(where: {$0.ticker == ticker}){
           modelContext.delete(filterTicker)
        }else{
            let portfolioModel = PortfolioModel(ticker: ticker, isSelected: true)
            modelContext.insert(portfolioModel)

        }
        
        
        
        
        getSavedTicker()
    }
    
    
}
