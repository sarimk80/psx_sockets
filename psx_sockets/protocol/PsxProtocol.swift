//
//  PsxProtocol.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation

enum IndexEnums:String {
    case kse_100
    case kse_30
    case psx_div_20
    case mii_30
    case kmi_30
}

protocol PsxProtocol{
    func psxStats (type:String) async throws -> PsxStatsModel
    
    func psxCompanies(symbol:String) async throws -> PsxCompaniesModel
    
    func psxfundamentals (symbol:String) async throws -> PsxFundamentalsModel
    
    func psxDividend(symbol:String) async throws -> PsxDividendModel
    
    func psxKline(symbol:String,timeFrame:String) async throws -> KLineRequestModel
    
    func getDividend() async throws -> [DividendModel]
    
    func getIndexDetail(index:IndexEnums)async throws -> [IndexDetailModel]
    
    func getAllStocksDetail() async throws -> SectorPsxResponse
}
