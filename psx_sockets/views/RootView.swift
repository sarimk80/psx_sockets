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
            Tab("", systemImage: "house") {
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

            Tab("",systemImage: "chart.pie"){

                NavigationStack {
                    SectorView()
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
