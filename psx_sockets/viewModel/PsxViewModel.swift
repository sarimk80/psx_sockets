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

enum SymbolOverviewEnums {
    case initial
    case loading
    case loaded(overview : SymbolOverview)
    case error(errorMessage:String)
}

enum IndicesEnums{
    case initial
    case loading
    case loaded(indicesData : [SymbolDetail])
    case error(errorMessage:String)
}

enum PortfolioTickerEnum{
    case initial
    case loading
    case loaded(portfolioTickers : [SymbolDetail])
    case error(errorMessage:String)
}

enum SymbolDetailEnums {
    case initial
    case loading
    case loaded(portfolioTickers : SymbolDetail)
    case error(errorMessage:String)
}

enum SectorSymbolEnum{
    case initial
    case loading
    case loaded(portfolioTickers : [SymbolDetail])
    case error(errorMessage:String)
}
enum TickerPriceEnum : Equatable {
    case initial
    case loading
    case loaded(tickerPrice:TickerPriceModel)
    case error(errorMessage:String)
}

enum TransactionDetailEnums {
    case initial
    case loading
    case loaded(portfolioTickers : [Transaction])
    case error(errorMessage:String)
}

enum ClearDataEnums{
    case initial
    case loading
    case loaded
    case error(errorMessage:String)
}


@MainActor
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
    var symbolOverviewEnums: SymbolOverviewEnums = .initial
    var indicesEnums: IndicesEnums = .initial
    var portfolioEnums: PortfolioTickerEnum = .initial
    var symbolDetailEnum : SymbolDetailEnums = .initial
    var sectorSymbolEnum : SectorSymbolEnum = .initial
    var tickerPriceEnum : TickerPriceEnum = .initial
    var transactionDetailEnum : TransactionDetailEnums = .initial
    var clearDataEnum : ClearDataEnums = .initial
    
    // for Index Detail symbols
    
    var indexSymbols: [SymbolDetail] = []
    var isLoading = false
    var errorMessage: String?
    
    //
    
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
    
    func getSymbolOverview(symbol:String) async{
        self.symbolOverviewEnums = .loading
        do{
            let data = try await psxServiceManager.getSymbolOverview(symbol: symbol)
            
            let sortedAnnouncements = data.announcements.sorted { $0.date < $1.date }
            let sortedRatios = data.ratios.sorted { ($0.period ?? "") < ($1.period ?? "") }
            let sortedAnnual = data.financials.annual.sorted{ ($0.period ?? "") < ($1.period ?? "") }
            
            let sortedQuatelry = data.financials.quarterly.sorted{ ($0.period ?? "") < ($1.period ?? "") }
            
            let symbolOverview = SymbolOverview(announcements: sortedAnnouncements, financials: Financials(annual: sortedAnnual, quarterly: sortedQuatelry), ratios: sortedRatios, timestamp: data.timestamp)
            
            self.symbolOverviewEnums = .loaded(overview: symbolOverview)
        }catch(let error){
            self.symbolOverviewEnums = .error(errorMessage: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    func getIndexSymbolDetail(indices:[String]) async{
        self.indicesEnums = .loading
        var response:[SymbolDetail] =  []
        response.reserveCapacity(indices.count)
        
        do{
            for index in indices {
                let data = try await psxServiceManager.getSymbolDetail(market: "IDX", symbol: index)
                
                response.append(data)
                
                try await Task.sleep(for: .milliseconds(250))
            }
            self.indicesEnums = .loaded(indicesData: response)
                        
        }catch{
            self.indicesEnums = .error(errorMessage: error.localizedDescription)
        }
    }
    
    func getIndexSymbolAllDetail(indexEnum: IndexEnums) async {
        
        print("🟡 Starting getIndexSymbolAllDetail")
        isLoading = true
        errorMessage = nil
        indexSymbols.removeAll()
        
        do {
            print("🔵 Fetching index data...")
            let indexData = try await psxServiceManager.getIndexDetail(index: indexEnum)
            print("✅ Got index data: \(indexData.count) symbols")
            
            let firstBatch = Array(indexData.prefix(10))
            let remaining = Array(indexData.dropFirst(10))
            
            // 🚀 BURST LOAD (parallel)
            print("🚀 Starting parallel load of first 10...")
            try await withThrowingTaskGroup(of: SymbolDetail.self) { group in
                
                for item in firstBatch {
                    group.addTask {
                        print("   📡 Fetching \(item.symbol)...")
                        let result = try await self.psxServiceManager
                            .getSymbolDetail(market: "REG", symbol: item.symbol)
                        print("   ✅ Got \(item.symbol)")
                        
                        let dataWithSector = SymbolDataClass(market: result.data.market, st: result.data.st, symbol: result.data.symbol, price: result.data.price, change: result.data.change, changePercent: result.data.changePercent, volume: result.data.volume, trades: result.data.trades, value: result.data.value, high: result.data.high, low: result.data.low, bid: result.data.bid, ask: result.data.ask, bidVol: result.data.bidVol, askVol: result.data.askVol, timestamp: result.timestamp,sectorName: item.name,portfolioVolume: 1,fullName: item.name)
                        
                        return SymbolDetail(
                            success: result.success,
                            data: dataWithSector,
                            timestamp: result.timestamp
                        )
                    }
                }
                
                for try await result in group {
                   
                    self.indexSymbols.append(result)
                    
                }
            }
            
            print("🔥 Setting isLoading to false")
            await MainActor.run {
                self.isLoading = false
            }
            
            // 🌊 STREAM the rest (sequential)
            print("🌊 Starting sequential load of remaining \(remaining.count)...")
            for (index, item) in remaining.enumerated() {
                
                try Task.checkCancellation()
                
                print("   📡 Fetching \(index + 1)/\(remaining.count): \(item.symbol)...")
                let result = try await psxServiceManager
                    .getSymbolDetail(market: "REG", symbol: item.symbol)
                print("   ✅ Got \(item.symbol)")
                
                let dataWithSector = SymbolDataClass(market: result.data.market, st: result.data.st, symbol: result.data.symbol, price: result.data.price, change: result.data.change, changePercent: result.data.changePercent, volume: result.data.volume, trades: result.data.trades, value: result.data.value, high: result.data.high, low: result.data.low, bid: result.data.bid, ask: result.data.ask, bidVol: result.data.bidVol, askVol: result.data.askVol, timestamp: result.timestamp,sectorName: item.sector,portfolioVolume: 1,fullName: item.name)
                
                let symbolDetail = SymbolDetail(
                    success: result.success,
                    data: dataWithSector,
                    timestamp: result.timestamp
                )
                
                    self.indexSymbols.append(symbolDetail)
                
                
                // small delay prevents API throttling
                try await Task.sleep(for: .milliseconds(700))
            }
            
            print("🎉 All data loaded! Total: \(indexSymbols.count) items")
            
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            
        }
    }
    
    
    func getPortfolioSymbolDetail() async{
        
        portfolioEnums = .loading
        
        
        let data = swiftDataService.getSavedTicker()
        
        var symbolResponse:[SymbolDetail] =  []
        symbolResponse.reserveCapacity(data.count)
        
        do{
            for result in data{
             let response = try await psxServiceManager.getSymbolDetail(market: "REG", symbol: result.ticker)
                
                let dataWithSector = SymbolDataClass(market: response.data.market, st: response.data.st, symbol: response.data.symbol, price: response.data.price, change: response.data.change, changePercent: response.data.changePercent, volume: response.data.volume, trades: response.data.trades, value: response.data.value, high: response.data.high, low: response.data.low, bid: response.data.bid, ask: response.data.ask, bidVol: response.data.bidVol, askVol: response.data.askVol, timestamp: response.timestamp,sectorName: nil,portfolioVolume: result.transaction.reduce(0){$0 + $1.volume},fullName: "")
                
                symbolResponse.append(  SymbolDetail(
                        success: response.success,
                        data: dataWithSector,
                        timestamp: response.timestamp
                        )
                  )
                
                try await Task.sleep(for: .milliseconds(600))
               
            }
            
            portfolioEnums = .loaded(portfolioTickers: symbolResponse)
            
        }catch{
            print(error.localizedDescription)
            portfolioEnums = .error(errorMessage: error.localizedDescription)
        }
        
    }
    
    func getSymbolDetail(ticker:String) async {
        symbolDetailEnum = .loading
        do{
          let response = try await psxServiceManager.getSymbolDetail(market: "REG", symbol: ticker)
            
            symbolDetailEnum = .loaded(portfolioTickers: response)
        }catch{
            symbolDetailEnum = .error(errorMessage: error.localizedDescription)
        }
    }
    
    
    func getSectorSymbolDetail(tickers:[String]) async{
        sectorSymbolEnum = .loading
        var sectorSymbol: [SymbolDetail] = []
        sectorSymbol.reserveCapacity(tickers.count)
        do{
            
            let firstBatch = Array(tickers.prefix(10))
            let remaining = Array(tickers.dropFirst(10))
            
            try await withThrowingTaskGroup(of: SymbolDetail.self) { group in
               
                for ticker in firstBatch{
                    group.addTask{
                     let result =  try await self.psxServiceManager.getSymbolDetail(market: "REG", symbol: ticker)
                        
                        let dataWithSector = SymbolDataClass(market: result.data.market, st: result.data.st, symbol: result.data.symbol, price: result.data.price, change: result.data.change, changePercent: result.data.changePercent, volume: result.data.volume, trades: result.data.trades, value: result.data.value, high: result.data.high, low: result.data.low, bid: result.data.bid, ask: result.data.ask, bidVol: result.data.bidVol, askVol: result.data.askVol, timestamp: result.timestamp,sectorName: "",portfolioVolume: 1,fullName: "")
                        
                        return SymbolDetail(
                            success: result.success,
                            data: dataWithSector,
                            timestamp: result.timestamp
                        )
                    }
                }
                
                for try await result in group{
                    sectorSymbol.append(result)
                }
            }
            sectorSymbolEnum = .loaded(portfolioTickers: sectorSymbol)
            
            for remainingTicker in remaining {
                
                let result = try await self.psxServiceManager.getSymbolDetail(market: "REG", symbol: remainingTicker)
                
                let dataWithSector = SymbolDataClass(market: result.data.market, st: result.data.st, symbol: result.data.symbol, price: result.data.price, change: result.data.change, changePercent: result.data.changePercent, volume: result.data.volume, trades: result.data.trades, value: result.data.value, high: result.data.high, low: result.data.low, bid: result.data.bid, ask: result.data.ask, bidVol: result.data.bidVol, askVol: result.data.askVol, timestamp: result.timestamp,sectorName: "",portfolioVolume: 1,fullName: "")
                
                let symbolDetail = SymbolDetail(
                    success: result.success,
                    data: dataWithSector,
                    timestamp: result.timestamp
                )
                
                sectorSymbol.append(symbolDetail)
                
                sectorSymbolEnum = .loaded(portfolioTickers: sectorSymbol)
                
                try await Task.sleep(for: .milliseconds(700))
                
            }
            
        }catch{
            sectorSymbolEnum = .error(errorMessage: error.localizedDescription)
        }
    }
    
    func getTickerPrice(ticker:String) async{
        self.tickerPriceEnum = TickerPriceEnum.initial
        do{
            let response = try await psxServiceManager.getTickerPrice(symbol: ticker)
            self.tickerPriceEnum = TickerPriceEnum.loaded(tickerPrice: response)
        }
        catch(let error){
            self.tickerPriceEnum = TickerPriceEnum.error(errorMessage: error.localizedDescription)
        }
    }
    
    func getSingleTransactionDetail(ticker:String) async{
        
        transactionDetailEnum = TransactionDetailEnums.loading
        
        let singlePortfolio =  swiftDataService.getSingleTicker(ticker: ticker)
        
        
        let transaction = singlePortfolio?.transaction ?? []
        
        
        do{
            
            transactionDetailEnum = .loaded(portfolioTickers: transaction)
            
        }catch{
            print(error.localizedDescription)
            transactionDetailEnum = .error(errorMessage: error.localizedDescription)
        }
    }
    
    func clearAllData()async{
        clearDataEnum = .loading
        swiftDataService.clearAllData()
        clearDataEnum  = .loaded
        
    }

}
