//
//  PsxServiceManager.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import Foundation


class PsxServiceManager:PsxProtocol{
    func psxStats(type: String) async throws -> PsxStatsModel {
        guard let url = URL(string: "https://psxterminal.com/api/stats/\(type)")
        else {  throw URLError(.badURL) }
              
        let (data,response) = try await URLSession.shared.data(from: url)
              
              
        guard let response = response as? HTTPURLResponse,
                    
                response.statusCode == 200
                      
                      
        else { throw URLError(.badServerResponse) }
              
        if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
              
              
        let decodeResponse = try JSONDecoder().decode(PsxStatsModel.self, from: data)
              
        return decodeResponse
    }
    
    func psxCompanies(symbol: String) async throws -> PsxCompaniesModel {
        guard let url = URL(string: "https://psxterminal.com/api/companies/\(symbol)")
        else {  throw URLError(.badURL) }
              
        let (data,response) = try await URLSession.shared.data(from: url)
              
              
        guard let response = response as? HTTPURLResponse,
                    
                response.statusCode == 200
                      
                      
        else { throw URLError(.badServerResponse) }
              
        if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
              
              
        let decodeResponse = try JSONDecoder().decode(PsxCompaniesModel.self, from: data)
        
        return decodeResponse
              
        
    }
    
    func psxfundamentals(symbol: String) async throws -> PsxFundamentalsModel {
        guard let url = URL(string: "https://psxterminal.com/api/fundamentals/\(symbol)")
        else {  throw URLError(.badURL) }
              
        let (data,response) = try await URLSession.shared.data(from: url)
              
              
        guard let response = response as? HTTPURLResponse,
                    
                response.statusCode == 200
                      
                      
        else { throw URLError(.badServerResponse) }
              
        if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
              
              
        let decodeResponse = try JSONDecoder().decode(PsxFundamentalsModel.self, from: data)
        
        return decodeResponse
    }
    
    func psxDividend(symbol: String) async throws -> PsxDividendModel {
        guard let url = URL(string: "https://psxterminal.com/api/dividends/\(symbol)")
        else {  throw URLError(.badURL) }
              
        let (data,response) = try await URLSession.shared.data(from: url)
              
              
        guard let response = response as? HTTPURLResponse,
                    
                response.statusCode == 200
                      
                      
        else { throw URLError(.badServerResponse) }
              
        if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
              
              
        let decodeResponse = try JSONDecoder().decode(PsxDividendModel.self, from: data)
        
        return decodeResponse
    }
    
    func getAllSymbols() async throws -> AllSymbolsModel{
        guard let url = URL(string: "https://psxterminal.com/api/symbols")
        else {  throw URLError(.badURL) }
              
        let (data,response) = try await URLSession.shared.data(from: url)
              
              
        guard let response = response as? HTTPURLResponse,
                    
                response.statusCode == 200
                      
                      
        else { throw URLError(.badServerResponse) }
              
        if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
              
              
        let decodeResponse = try JSONDecoder().decode(AllSymbolsModel.self, from: data)
        
        return decodeResponse
    }
    
}
