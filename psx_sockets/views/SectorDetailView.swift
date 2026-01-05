//
//  SectorDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 23/12/2025.
//

import SwiftUI

struct SectorDetailView: View {
    let sectorName: String
    let data: SectorDataModel
    
    @Environment(WebSocketManager.self) private var socketManager
    @Bindable var appNavigation:SectorNavigation
    
    
    var body: some View {
        List{
            SectorCardView(sectorName: sectorName, data: data)
                .listRowSeparator(.hidden)
            if(socketManager.portfolioUpdate.isEmpty){
                ProgressView()
            }else{
                ForEach(socketManager.portfolioUpdate,id: \.symbol) { result in
                    PortfolioStockRow(result: result)
                        .onTapGesture {
                            appNavigation.push(route: SectorNavigationEnums.tickerDetail(symbol: result.symbol))
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                }
            }
            
        }
        .navigationTitle(sectorName)
        .listStyle(.plain)
        .task {
            await socketManager.getMarketUpdate(tickers: data.symbols, market: "REG", inIndex: false)
        }
    }
}

