//
//  WebSocketManager.swift
//  psx_sockets
//
//  Created by sarim khan on 21/08/2025.
//

import Foundation
import Combine

@Observable
class WebSocketManager{
    
    private var swiftDataService:SwiftDataService = SwiftDataService()
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let urlSession = URLSession(configuration: .default)
    
    private var cancellable: AnyCancellable?
    
    var tickerUpdate:TickerUpdate?
    var klineModel:KlineModel?
    var portfolioUpdate:[TickerUpdate] = []
    var isLoading:Bool = true
    
    private var selectedSymbol:String = "KSE100"
    
    private var subKey:String?
    private var subKeys:[String] = []
    
    private var psxServiceManager:PsxServiceManager = PsxServiceManager()
    
    
    
    init() {
        
        guard webSocketTask == nil else{
            print("Already connected")
            return
        }
        connectWebSockets()
    }
    
    func connectWebSockets(){
        guard let url = URL(string: "wss://psxterminal.com/") else { return }
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        receivedMessage()
    }
    
    func receivedMessage(){
        webSocketTask?.receive {[weak self] results in
            switch results {
            case .success(let success):
                
                self?.readMessage(message: success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                    self?.receivedMessage()
                }
                
                
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func readMessage(message: URLSessionWebSocketTask.Message){
        guard case .string(let text) = message,
              let data = text.data(using: .utf8) else{ return }
        do{
            let base = try JSONDecoder().decode(BaseMessage.self, from: data)
            
            switch base.type {
            case "ping":
                let ping = try JSONDecoder().decode(PingPongModel.self, from: data)
                sendPong(timeStamp: ping.timestamp)
            case "welcome":
                let welcome = try JSONDecoder().decode(WelcomeModel.self, from: data)
                print(welcome.message)
            case "tickUpdate":
                let tick = try JSONDecoder().decode(TickerUpdate.self, from: data)
                self.tickerUpdate = tick
                updateListRealTime()
                
                print(tick.symbol)
                print(tick.market)
                print(tick.type)
                print(tick.tick.c)
            case "unsubscribeResponse":
                print("UnSubscribe")
            case "subscribeResponse":
                let response = try JSONDecoder().decode(SubscribeResponseModel.self, from: data)
                print(response)
                self.subKey = response.subscriptionKey
                self.subKeys.append(response.subscriptionKey)
                print(subKeys)
            case "klines":
                let response = try JSONDecoder().decode(KlineModel.self, from: data)
                self.klineModel = response
            default:
                print(String(describing: data))
            }
            
        }catch(let error){
            print(error.localizedDescription)
        }
        
        
    }
    
    func sendPong(timeStamp:Int){
        do{
            let pong = PingPongModel(type: "pong", timestamp: timeStamp)
            let data = try JSONEncoder().encode(pong)
            guard let string = String(data: data, encoding: .utf8) else { return  }
            webSocketTask?.send(.string(string)) { error in
                print(error.debugDescription)
            }
            print("message send")
        }catch{
            
        }
       
    }
    
    func getSymbolDetailRealTime(symbol:String){
        do{
            let subParameters = SubscriptionParameters(type: "subscribe", subscriptionType: "marketData", params: Params(symbol: symbol), requestID: UUID().uuidString)
            let data = try JSONEncoder().encode(subParameters)
            guard let string = String(data: data, encoding: .utf8) else { return  }
            webSocketTask?.send(.string(string)) { error in
                print(error.debugDescription)
            }
            print("message send for symbol")
        }catch(let error){
            print(error.localizedDescription)
        }
    }
    
    func unSubscribeStream(symbol:String,market:String) async{
        do{
            
            self.tickerUpdate = nil
            
            let response =   try await psxServiceManager.getSymbolDetail(market: market, symbol: symbol)
            
            self.tickerUpdate = TickerUpdate(type: "tickUpdate", symbol: symbol, market: market, tick: Tick(m: market, st: response.data.st, s: symbol, t: response.data.timestamp, o: 0.0, h: response.data.high, l: response.data.low, c: response.data.price, v: response.data.volume, ldcp: 0.0, ch: response.data.change, pch: response.data.changePercent, bp: Double(response.data.bid), bv: response.data.bidVol, ap: Double(response.data.ask), av: response.data.askVol, val: response.data.value, tr: response.data.timestamp), timestamp: response.timestamp)
            
            
            if let subKeyPresent = subKey{
                let unSubscribeModel = UnSubscriptionModel(type: "unsubscribe", subscriptionKey: subKeyPresent, requestId: UUID().uuidString)
                
                let data = try JSONEncoder().encode(unSubscribeModel)
                
                guard let string = String(data: data, encoding: .utf8) else { return  }
                
                webSocketTask?.send(.string(string)) { error in
                    print(error.debugDescription)
                }
                getSymbolDetailRealTime(symbol: symbol)

                
            }else{
                getSymbolDetailRealTime(symbol: symbol)
            }
            
            
            
            
        }catch(let error){
            print(error.localizedDescription)
        }
    }
    
    func KlineSteam(symbol:String){
        do{
            print("kline \(symbol)")
            let kline = klineSubModel(type: "klines", symbol: symbol, timeframe: "1d", requestId: UUID().uuidString)
            let data = try JSONEncoder().encode(kline)
            
            guard let string = String(data: data, encoding: .utf8) else { return  }
            
            webSocketTask?.send(.string(string)) { error in
                print(error.debugDescription)
            }
            
            print("kline \(symbol) done")
            
        }catch(let error){
            print(error.localizedDescription)
        }
    }
    
    func getRealTimeTickersUpdate(isIndex:Bool = false) async{
        self.portfolioUpdate.removeAll()
        self.isLoading = true
        let data = swiftDataService.getSavedTicker()
        let tickers = data.map { $0.ticker }
        let volume = data.map{ $0.volume ?? 1 }
        await getPortfolioRealTime(tickers: tickers,market: "REG",isIndex: isIndex,volume: volume)
    }
    
    func getMarketUpdate(tickers:[String],market:String,inIndex:Bool)async{
        self.portfolioUpdate.removeAll()
        let volume = [Int](repeating: 1, count: tickers.count)
        await getPortfolioRealTime(tickers: tickers,market: market,isIndex: inIndex,volume: volume)
    }
    
    func getPortfolioRealTime(tickers:[String],market:String,isIndex:Bool,volume:[Int]) async {
        
        do{
            //model
            // make api call to get all the tickers detail
            
            for (index,model) in tickers.enumerated() {
                let result = try await psxServiceManager.getSymbolDetail(market: market,symbol: model)
                self.portfolioUpdate.append(TickerUpdate(type: "tickUpdate", symbol: result.data.symbol, market: result.data.market, tick: Tick(m: market, st: result.data.st, s: model, t: result.data.timestamp, o: 0.0, h: result.data.high, l: result.data.low, c: result.data.price, v: result.data.volume, ldcp: 0.0, ch: result.data.change, pch: result.data.changePercent, bp: Double(result.data.bid), bv: result.data.bidVol, ap: Double(result.data.ask), av: result.data.askVol, val: result.data.value, tr: result.data.timestamp,volume: volume[index]), timestamp: result.timestamp))
                
            }
            self.isLoading = false
            print("Subkeys")
            print(subKeys.count)
            // unsubscribe all the subscribe tickers
            for key in subKeys {
                let unSubscribeModel = UnSubscriptionModel(type: "unsubscribe", subscriptionKey: key, requestId: UUID().uuidString)
                
                let data = try JSONEncoder().encode(unSubscribeModel)
                
                guard let string = String(data: data, encoding: .utf8) else { return  }
                
                webSocketTask?.send(.string(string)) { error in
                    print(error.debugDescription)
                }
            }
            self.subKeys.removeAll()
            
            // subscribe to all the new tickers
            //for model in tickers{
            if(isIndex){
                getSymbolDetailRealTime(symbol: tickers.first ?? "KSE100")
            }
            //}
            
        }catch(let error){
            print(error.localizedDescription)
        }
        
    }
    
    func updateListRealTime(){
        
        if let tick = self.tickerUpdate ,
            let index = portfolioUpdate.firstIndex(where: {$0.symbol == tick.symbol}){
            
            var updateTick = self.portfolioUpdate[index]
            var tickUpdate = self.portfolioUpdate[index].tick
            
            tickUpdate.ap = tick.tick.ap
            tickUpdate.av = tick.tick.av
            tickUpdate.bp = tick.tick.bp
            tickUpdate.bv = tick.tick.bv
            tickUpdate.c = tick.tick.c
            tickUpdate.ch = tick.tick.ch
            tickUpdate.h = tick.tick.h
            tickUpdate.l = tick.tick.l
            tickUpdate.ldcp = tick.tick.ldcp
            tickUpdate.m = tick.tick.m
            tickUpdate.o = tick.tick.o
            tickUpdate.pch = tick.tick.pch
            tickUpdate.s = tick.tick.s
            tickUpdate.st = tick.tick.st
            tickUpdate.t = tick.tick.t
            tickUpdate.tr = tick.tick.tr
            tickUpdate.v = tick.tick.v
            tickUpdate.val = tick.tick.val
            
            updateTick.market = tick.market
            updateTick.timestamp = tick.timestamp
            updateTick.tick = tickUpdate
            
            
                
            self.portfolioUpdate[index] = updateTick
            
            }
            
            
        
    }
    
}
