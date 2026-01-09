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

enum PortfolioEnum{
    case initial
    case loading
    case loaded(data:[PsxFundamentalsModel])
    case error(errorMessage:String)
}

enum KlineEnums{
    case initial
    case loading
    case loaded(data:KLineRequestModel)
    case error(errorMessage:String)
}

enum DividendEnums{
    case initial
    case loading
    case loaded(data:[DividendModel])
    case error(errorMessage:String)
}

enum IndexDetailEnums{
    case initial
    case loading
    case loaded(data:[IndexDetailModel],groupData:[SortedData])
    case error(errorMessage:String)
}

enum HotStocksEnums {
    case initial
    case loading
    case loaded(gainers:[SectorStocks],losers:[SectorStocks],mostActive:[SectorStocks])
    case error(errorMessage:String)
}

@Observable
class PsxViewModel{
    var psxStats:PsxStatsEnum = PsxStatsEnum.initial
    var psxCompany:PsxCompanyDetailEnums = PsxCompanyDetailEnums.initial
    var psxSearch : PsxSearchSymbolEnum = PsxSearchSymbolEnum.initial
    var psxSector : PsxSectorEnum = PsxSectorEnum.initial
    var portfolioData : PortfolioEnum = PortfolioEnum.initial
    var kLineEnum : KlineEnums = KlineEnums.initial
    var dividendEnums : DividendEnums = DividendEnums.initial
    var indexDetailEnum: IndexDetailEnums = IndexDetailEnums.initial
    var hotStockEnum: HotStocksEnums = HotStocksEnums.initial
    
    var symbolSearch:String = ""
    
    var listOfSymbols:[String] = []
    private var portfolioDataResult : [PsxFundamentalsModel] = []
    
    private let psxServiceManager:PsxServiceManager
    
    private let swiftDataService = SwiftDataService()
    
    init(psxServiceManager: PsxServiceManager) {
        self.psxServiceManager = psxServiceManager
    }
    
    func getPsxMarketStats() async{
        do{
            self.hotStockEnum = HotStocksEnums.loading
            let stocks = try await psxServiceManager.getAllStocksDetail()
           
            let allStocks = stocks.sectors.values.flatMap{$0}
            
            
            let gainers = allStocks.filter{$0.trend == "increase"}
                .sorted{Double($0.change) ?? 0.0 > Double($1.change) ?? 0.0}
                .prefix(10)
                .map{$0}
            
            let losers = allStocks.filter{$0.trend == "decrease"}
                .sorted{Double($0.change) ?? 0.0 < Double($1.change) ?? 0.0}
                .prefix(10)
                .map{$0}
            
            let mostActive = allStocks
                .sorted{Double($0.volume) ?? 0.0 > Double($1.volume) ?? 0.0 }
                .prefix(10)
                .map{$0}
            

            self.hotStockEnum = HotStocksEnums.loaded(gainers: gainers, losers: losers, mostActive: mostActive)
        }catch(let error){
            self.hotStockEnum = HotStocksEnums.error(errorMessage: error.localizedDescription)
        }
    }
    //debugDescription    String    "No value associated with key CodingKeys(stringValue: \"sectors\", //intValue: nil) (\"sectors\")."
    
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
        
        if(!symbolSearch.isEmpty && symbolSearch.count > 1){

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
    
    func getPortfolioData() async{
        do{
            portfolioDataResult.removeAll()
        self.portfolioData = PortfolioEnum.loading
            let data = swiftDataService.getSavedTicker()
            
            for model in data {
                let result = try await psxServiceManager.psxfundamentals(symbol: model.ticker)
                portfolioDataResult.append(result)
            }
        self.portfolioData = PortfolioEnum.loaded(data: portfolioDataResult)
            
        }catch(let error){
            self.portfolioData = PortfolioEnum.error(errorMessage: error.localizedDescription)
        }
    }
    
    func getKlineSymbol(symbol:String,timeFrame:String)async{
        self.kLineEnum = KlineEnums.loading
        do{
          let result =  try await psxServiceManager.psxKline(symbol: symbol, timeFrame: timeFrame)
            self.kLineEnum = KlineEnums.loaded(data: result)
        }catch(let error){
            self.kLineEnum = KlineEnums.error(errorMessage: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    func getDividendData()async{
        self.dividendEnums = DividendEnums.loading
        do{
            let data = try await psxServiceManager.getDividend()
            self.dividendEnums = DividendEnums.loaded(data: data)
        }catch(let error){
            self.dividendEnums = DividendEnums.error(errorMessage: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    //IndexDetailEnums
    
    func getIndexData(indexEnum:IndexEnums)async{
        self.indexDetailEnum = IndexDetailEnums.loading
        var sortedData:[SortedData] = []
        do{
            let data = try await psxServiceManager.getIndexDetail(index: indexEnum)
            let groupData = Dictionary(grouping:data,by: {$0.sector})
            let sortedSector = groupData.sorted(by: {$0.key < $1.key})
            
           
            sortedSector.forEach { sectorName, item in
                sortedData.append(SortedData(sectorName: sectorName, sectorStockCount: item.count))
            }
            
            
            self.indexDetailEnum = IndexDetailEnums.loaded(data: data,groupData: sortedData)
        }catch(let error){
            self.indexDetailEnum = IndexDetailEnums.error(errorMessage: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    
}
