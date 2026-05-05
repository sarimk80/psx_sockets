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
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Bindable var appNavigation:SectorNavigation
    
    
    var body: some View {
        List{
            SectorCardView(sectorName: sectorName, data: data)
                .listRowSeparator(.hidden)
            
            switch psxViewModel.sectorSymbolEnum {
            case .initial, .loading:
                ForEach(0..<5) { _ in
                    PortfolioStockRow(result: SymbolDataClass.mock)
                        .redacted(reason: .placeholder)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                
            case .loaded(let portfolioTickers):
                ForEach(portfolioTickers,id: \.data.symbol) { result in
                    PortfolioStockRow(result: result.data)
                        .onTapGesture {
                            appNavigation.push(route: SectorNavigationEnums.tickerDetail(symbol: result.data.symbol))
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            case .error(let errorMessage):
                ErrorView(message: errorMessage)
            }
            
            
        }
        .navigationTitle(sectorName)
        .listStyle(.plain)
        .task {
            
            if case SectorSymbolEnum.initial = psxViewModel.sectorSymbolEnum{
                await psxViewModel.getSectorSymbolDetail(tickers: data.symbols)
            }
            
        }
    }
}

