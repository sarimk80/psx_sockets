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
    
    private var subKey:String = ""
    
    
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
                print(tick.tick.c)
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
    
    func unSubscribeStream(symbol:String){
        do{
            let unSubscribeModel = UnSubscriptionModel(type: "unsubscribe", subscriptionKey: subKey, requestId: UUID().uuidString)
            
            let data = try JSONEncoder().encode(unSubscribeModel)
            
            guard let string = String(data: data, encoding: .utf8) else { return  }
            
            webSocketTask?.send(.string(string)) { error in
                print(error.debugDescription)
            }
            
            print("UnSubscribe")
            
            
        }catch(let error){
            print(error.localizedDescription)
        }
    }
    
    func KlineSteam(symbol:String){
        do{
            print("kline \(symbol)")
            let kline = klineSubModel(type: "klines", symbol: symbol, timeframe: "1m", requestId: UUID().uuidString)
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
