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
    @State private var moreNavigation: MoreNavigation = MoreNavigation()
    
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
                            case .indexDetail(let indexName,let tickerDetail):
                                IndexDetailView(indexName: indexName,tickerDetail: tickerDetail, appNavigation: $appNavigation)
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
                            case .tickerTransaction(let symbol):
                                TransactionDetailView(symbol: symbol)
                            }
                        }
                }
                
            }
            
            Tab("Stocks",systemImage: "chart.bar",value: 2){

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
            
            
            
            Tab("More",systemImage: "ellipsis.rectangle.fill",value: 4){
                
                NavigationStack(path:$moreNavigation.moreNav) {
                    MoreView()
                        .environment(moreNavigation)
                        .navigationDestination(for: MoreNavigationEnums.self) { route in
                            switch route{
                            case .searchView:
                                SearchView(moreNavigation: $moreNavigation)
                            case .tickerDetail(let symbol):
                                TickerDetailView(symbol: symbol)
                            }
                            
                        }
                }
                
            }
        }
        .tabBarMinimizeBehavior(.automatic)
    }
}

#Preview {
    RootView()
}
