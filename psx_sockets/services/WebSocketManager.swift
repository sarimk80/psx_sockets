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
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let urlSession = URLSession(configuration: .default)
    
    private var cancellable: AnyCancellable?
    
    var tickerUpdate:TickerUpdate?
    var klineModel:KlineModel?
    
    private var selectedSymbol:String = "KSE100"
    
    private var subKey:String?
    
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
                
                print(tick.symbol)
                print(tick.market)
                print(tick.type)
            case "unsubscribeResponse":
                print("UnSubscribe")
            case "subscribeResponse":
                let response = try JSONDecoder().decode(SubscribeResponseModel.self, from: data)
                self.subKey = response.subscriptionKey
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
    
}
