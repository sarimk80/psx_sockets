//
//  RootView.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import SwiftUI

struct RootView: View {
    @State private var appNavigation:AppNavigation = AppNavigation()
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack(path:$appNavigation.tickerNavigation) {
                    ContentView()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(let symbol,let data):
                                CorporationDetailView(corporation: symbol, data: data)
                            }
                        }

                }
                
            }
            
            Tab("Stocks",systemImage: "flame"){

                NavigationStack(path: $appNavigation.tickerNavigation) {
                    HotStocks()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(let corporation,let data):
                                CorporationDetailView(corporation: corporation, data: data)
                            }
                        }
                }
                
            }

            Tab("Sectors",systemImage: "chart.pie"){

                NavigationStack {
                    SectorView()
                }
                
            }
            
            Tab("Portfolio",systemImage: "scroll"){

                NavigationStack(path:$appNavigation.tickerNavigation) {
                    PortfolioView()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(sectionName: let sectionName, data: let data):
                                CorporationDetailView(corporation: sectionName, data: data)

                            }
                        }
                }
                
            }
            
            Tab("",systemImage: "magnifyingglass",role: .search){
                
                NavigationStack(path:$appNavigation.tickerNavigation) {
                    SearchView()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(sectionName: let sectionName, data: let data):
                                CorporationDetailView(corporation: sectionName, data: data)

                            }
                        }
                }
                
            }
            
            
            
            
            
        }
    }
}

#Preview {
    RootView()
}
