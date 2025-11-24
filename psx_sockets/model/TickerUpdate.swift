//
//  TickerUpdate.swift
//  psx_sockets
//
//  Created by sarim khan on 26/08/2025.
//

import Foundation


struct TickerUpdate :Codable,Hashable{
    
    let  type:String//": "tickUpdate",
    let  symbol:String//": "AIRLINK",
    var  market:String//": "REG",
    var tick:Tick//": ,
    var timestamp:Int//": 1750762129000
    
    var id:String {symbol}
    
}

struct Tick :Codable,Hashable{
    
    var m, st, s: String
    var t: Int
    var o, h, l, c: Double
    var v: Int
    var ldcp, ch, pch, bp: Double
    var bv: Int
    var ap: Double
    var av: Int
    var val: Double
    var tr: Int
    
}



