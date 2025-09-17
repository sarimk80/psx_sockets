//
//  ViewModel.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation
import Combine

enum PsxStatsEnum{
    case initial
    case loading
    case loaded(data:PsxStatsModel)
    case error(errorMessage:String)
}

enum PsxCompanyDetailEnums{
    case initial
    case loading
    case loaded(company:PsxCompaniesModel,dividend:PsxDividendModel,fundamental:PsxFundamentalsModel)
    case error(errorMessage:String)
}

enum PsxSearchSymbolEnum{
    case initial
    case loading
    case allSymbolLoaded(allSymbol:[String])
    case loaded(data:[String])
    case error(errorMessage:String)
}

enum PsxSectorEnum {
    case initial
    case loading
    case loaded(data:SectorModel)
    case error(errorMessage:String)
}

@Observable
class PsxViewModel{
    var psxStats:PsxStatsEnum = PsxStatsEnum.initial
    var psxCompany:PsxCompanyDetailEnums = PsxCompanyDetailEnums.initial
    var psxSearch : PsxSearchSymbolEnum = PsxSearchSymbolEnum.initial
    var psxSector : PsxSectorEnum = PsxSectorEnum.initial
    var symbolSearch:String = ""
    
    var listOfSymbols:[String] = []
    
    private let psxServiceManager:PsxServiceManager
    
    init(psxServiceManager: PsxServiceManager) {
        self.psxServiceManager = psxServiceManager
    }
    
    func getPsxMarketStats() async{
        do{
            self.psxStats = PsxStatsEnum.loading
            let stats =  try await psxServiceManager.psxStats(type: "REG")
            self.psxStats = PsxStatsEnum.loaded(data: stats)
        }catch(let error){
            self.psxStats = PsxStatsEnum.error(errorMessage: error.localizedDescription)
        }
    }
    
    func getCompanyDetail(symbol:String)async{
        do{
            self.psxCompany = PsxCompanyDetailEnums.loading
            let detail = try await psxServiceManager.psxCompanies(symbol: symbol)
            let dividend = try await psxServiceManager.psxDividend(symbol: symbol)
            let fundamentals = try await psxServiceManager.psxfundamentals(symbol: symbol)
            
            self.psxCompany = PsxCompanyDetailEnums.loaded(company: detail, dividend: dividend, fundamental: fundamentals)
        }catch(let error){
            self.psxCompany = PsxCompanyDetailEnums.error(errorMessage: error.localizedDescription)
        }
    }
    
    func getAllSymbols()async{
        do{
            let symbols =   try await psxServiceManager.getAllSymbols()
            self.psxSearch = PsxSearchSymbolEnum.allSymbolLoaded(allSymbol: symbols.data)
            self.listOfSymbols = symbols.data
        }catch(let error){
            self.psxSearch = PsxSearchSymbolEnum.error(errorMessage: error.localizedDescription)
        }
    }
    
    func getFilteredSymbols()async{
        self.psxSearch = PsxSearchSymbolEnum.loading
        
        if(!symbolSearch.isEmpty && symbolSearch.count > 2){

            let searchSymbol = self.listOfSymbols.filter({$0.localizedCaseInsensitiveContains(symbolSearch)})
            
            self.psxSearch = PsxSearchSymbolEnum.loaded(data: searchSymbol)
 
        }else{
            self.psxSearch = PsxSearchSymbolEnum.loaded(data: self.listOfSymbols)
        }
    }
    
    func getPsxSector() async{
        self.psxSector = PsxSectorEnum.loading
        
        do{
            let sectors = try await psxServiceManager.getPsxSector()
            self.psxSector = PsxSectorEnum.loaded(data: sectors)
        }
        catch(let error){
            self.psxSector = PsxSectorEnum.error(errorMessage: error.localizedDescription)
        }
    }
}
