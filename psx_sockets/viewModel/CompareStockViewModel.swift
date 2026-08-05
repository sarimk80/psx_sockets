//
//  CompareStockViewModel.swift
//  psx_sockets
//
//  Created by sarim khan on 24/07/2026.
//

import Foundation


enum SearchSymbolEnums {
    
    case Loading
    case Initial
    case Loaded(symbols:[String])
    case Error(error:String)
    
}

enum CompareStockEnums {
    case Loading
    case Initial
    case Loaded(
        symbols:[SymbolDetail],
        symboloOverview:[SymbolOverview]
        )
    case Error(error:String)
}

@Observable
class CompareStockViewModel {
    
    var searchSymbolEnum:SearchSymbolEnums = .Initial
    var compareStockEnum: CompareStockEnums = .Initial
    
    var openBottomSheet:Bool = false
    var selectedSymbols:[String] = []
    
    var filterSymbolString:String = ""
    
    
    var searchedsymbol:[String] = []
    private let psxServiceManager:PsxServiceManager
    
    
    init(psxServiceManager: PsxServiceManager) {
        self.psxServiceManager = psxServiceManager
    }
    
    
    func getAllSymbols() async{
        
        searchSymbolEnum = .Loading
        
        do{
            let symbols = try await psxServiceManager.getAllSymbols()
            self.searchSymbolEnum = .Loaded(symbols: symbols)
            self.searchedsymbol = symbols
            
        }
        catch(let e){
            searchSymbolEnum = .Error(error: e.localizedDescription)
        }
    }
    
    func getAllFilterSymbols(){
        
        if(!filterSymbolString.isEmpty || filterSymbolString.count > 1){
            
            let filterSymbols =  self.searchedsymbol.filter { $0.lowercased() == filterSymbolString.lowercased() }
            
            self.searchSymbolEnum = .Loaded(symbols: filterSymbols)
        }else{
            self.searchSymbolEnum = .Loaded(symbols: self.searchedsymbol)
        }
        
    }
    
    
    func getAllSymbolDetail() async{
        
        self.compareStockEnum = .Loading
        var symbolResponse:[SymbolDetail] = []
        var symboloOverview:[SymbolOverview] = []
        
        for tickers in selectedSymbols {
            do{
                let response =  try await psxServiceManager.getSymbolDetail(market: "REG", symbol: tickers)
                
                let symbolOverviewResponse = try await psxServiceManager.getSymbolOverview(symbol: tickers)
                
                
                symbolResponse.append(response)
                symboloOverview.append(symbolOverviewResponse)
                
            
            }catch(let e){
                self.compareStockEnum = .Error(error: e.localizedDescription)
            }
        }
        
        self.compareStockEnum = .Loaded(symbols: symbolResponse,symboloOverview: symboloOverview)
    }
    
    
    func removeSymbol(symbol: String) {
        selectedSymbols.removeAll { $0 == symbol }

        guard case .Loaded(let symbols, let overview) = compareStockEnum else { return }

        
        guard let indexToRemove = symbols.firstIndex(where: { $0.data.symbol == symbol }) else {
            return 
        }

        var updatedSymbols = symbols
        var updatedOverview = overview
        updatedSymbols.remove(at: indexToRemove)
        if overview.indices.contains(indexToRemove) {
            updatedOverview.remove(at: indexToRemove)
        }

        compareStockEnum = updatedSymbols.isEmpty
            ? .Initial
            : .Loaded(symbols: updatedSymbols, symboloOverview: updatedOverview)
    }
}
