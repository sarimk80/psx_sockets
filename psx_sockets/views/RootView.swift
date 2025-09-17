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

                NavigationStack {
                    PortfolioView()
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
