//
//  PsxProtocol.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation

protocol PsxProtocol{
    func psxStats (type:String) async throws -> PsxStatsModel
    
    func psxCompanies(symbol:String) async throws -> PsxCompaniesModel
    
    func psxfundamentals (symbol:String) async throws -> PsxFundamentalsModel
    
    func psxDividend(symbol:String) async throws -> PsxDividendModel
    
    func psxKline(symbol:String,timeFrame:String) async throws -> KLineRequestModel
}
