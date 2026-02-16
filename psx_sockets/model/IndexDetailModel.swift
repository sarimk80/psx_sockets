//
//  IndexDetailModel.swift
//  psx_sockets
//
//  Created by sarim khan on 07/01/2026.
//

import Foundation


struct IndexDetailModel:Codable,Hashable {
    
    let name:String//": "HBL Growth Fund",
    let sector:String//": "Close-End Mutual Funds",
    let symbol:String//": "HGFA"
      
}


struct SortedData:Hashable,Identifiable {
    let sectorName:String
    let sectorStockCount:Int
    
    var id:String {sectorName}
    
}

