//
//  TickerUpdate.swift
//  psx_sockets
//
//  Created by sarim khan on 26/08/2025.
//

import Foundation


struct TickerUpdate :Codable{
    
    let  type:String//": "tickUpdate",
    let  symbol:String//": "AIRLINK",
    let  market:String//": "REG",
    let tick:Tick//": ,
    let timestamp:Int//": 1750762129000
    
}

struct Tick :Codable{
    
    let m, st, s: String
    let t: Int
    let o, h, l, c: Double
    let v: Int
    let ldcp, ch, pch, bp: Double
    let bv: Int
    let ap: Double
    let av: Int
    let val: Double
    let tr: Int
    
}
