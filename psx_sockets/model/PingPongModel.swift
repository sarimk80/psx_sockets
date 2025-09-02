//
//  PingPongModel.swift
//  psx_sockets
//
//  Created by sarim khan on 21/08/2025.
//

import Foundation


struct BaseMessage:Codable{
    let type:String
}

struct PingPongModel:Codable{
    let type:String
    let timestamp:Int
    
}

struct WelcomeModel:Codable{
    let type:String//": "welcome",
    let  message:String//": "Connected to PSX Terminal",
    let clientId:String//": "uuid-client-id"
    
}

struct SubscriptionParameters:Codable{
    let type, subscriptionType: String
        let params: Params
        let requestID: String

        enum CodingKeys: String, CodingKey {
            case type, subscriptionType, params
            case requestID = "requestId"
        }
    
}

struct Params: Codable {
    let symbol:String
}

struct UnSubscriptionModel:Codable{
    let type:String//": "unsubscribe",
    let subscriptionKey:String//": "marketData:REG",
    let requestId:String//": "req-002"
}

struct SubscribeResponseModel:Codable{
    
    let type:String//": "subscribeResponse",
    let  requestId:String//": "req-001",
    let status:String//": "success",
    let  subscriptionKey:String//": "marketData:REG"
    
}

struct klineSubModel:Codable {
    let type:String//": "klines",
    let symbol:String//": "AIRLINK",
    let timeframe:String//": "1m",
    let requestId:String//": "req-006"
}

