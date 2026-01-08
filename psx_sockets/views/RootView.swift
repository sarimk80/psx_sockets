//
//  RootView.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import SwiftUI

struct RootView: View {
    @State private var appNavigation:AppNavigation = AppNavigation()
    @State private var portfolioNavigation:PortfolioNavigation = PortfolioNavigation()
    @State private var sectorNavigation:SectorNavigation = SectorNavigation()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house",value: 0) {
                NavigationStack(path:$appNavigation.tickerNavigation) {
                    ContentView()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(let symbol,let data):
                                CorporationDetailView(corporation: symbol, data: data)
                            case .indexDetail( let indexName):
                                IndexDetailView(indexName: indexName,appNavigation: $appNavigation)
                            }
                        }

                }
                
            }
            
            
            Tab("Portfolio",systemImage: "scroll",value: 1){

                NavigationStack(path:$portfolioNavigation.portfolioNav) {
                    PortfolioView()
                        .environment(portfolioNavigation)
                        .navigationDestination(for: PortfolioNavigationEnums.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)

                            case .addTickerVolume(let symbol):
                                Text("Hello world \(symbol)")
                            }
                        }
                }
                
            }
            
            Tab("Stocks",systemImage: "chart.bar.fill",value: 2){

                NavigationStack(path: $appNavigation.tickerNavigation) {
                    HotStocks()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(let corporation,let data):
                                CorporationDetailView(corporation: corporation, data: data)
                            case .indexDetail(indexName: let indexName):
                                Text("")
                            }
                        }
                }
                
            }

            Tab("Sectors",systemImage: "square.grid.2x2.fill",value: 3){

                NavigationStack(path:$sectorNavigation.sectorNav) {
                    SectorView()
                        .environment(sectorNavigation)
                        .navigationDestination(for: SectorNavigationEnums.self) { route in
                            switch route{
                            case .sectorDetail(let sector,let sectorName):
                                SectorDetailView(sectorName: sectorName, data: sector,appNavigation: sectorNavigation)
                            case .tickerDetail(symbol: let symbol):
                                TickerDetailView(symbol: symbol)
                            }
                        }
                }
                
            }
            
            
            
            Tab("",systemImage: "magnifyingglass",value: 4, role: .search){
                
                NavigationStack(path:$appNavigation.tickerNavigation) {
                    SearchView()
                        .environment(appNavigation)
                        .navigationDestination(for: TickerDetailRoute.self) { route in
                            switch route{
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            case .corporationDetail(sectionName: let sectionName, data: let data):
                                CorporationDetailView(corporation: sectionName, data: data)

                            case .indexDetail(indexName: let indexName):
                                Text("")
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
