//
//  PortfolioView.swift
//  psx_sockets
//
//  Created by sarim khan on 10/09/2025.
//

import SwiftUI

struct PortfolioView: View {
    
    @State private var showSymbolsheet = false
    @State private var psxVM:PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var portfolioVM = PortfolioViewModel()
    @Environment(AppNavigation.self) private var appNavigation
    @Environment(WebSocketManager.self) private var socketManager
    
    var body: some View {
        VStack{
           if socketManager.portfolioUpdate.isEmpty {
                ProgressView()
           }else{
               List(socketManager.portfolioUpdate,id: \.symbol){result in
                   HStack{
                       Text(result.symbol)
                           .font(.subheadline)
                       Spacer()
                       VStack{
                           Text(result.tick.c,format: .number.precision(.fractionLength(2)))
                               .font(.headline)
                               .contentTransition(.numericText())
                           Text(result.tick.ch,format: .number.precision(.fractionLength(2)))
                               .font(.caption)
                               .foregroundStyle(result.tick.ch > 0 ? .green : .red)
                       }
                   }
                   .onTapGesture {
                       appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: result.symbol))
                   }
                   
                   
               }
           }
           
            
        }
        .navigationTitle("Portfolio")

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "rectangle.portrait.badge.plus") {
                    self.showSymbolsheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showSymbolsheet) {
            SheetView(psxViewModel: $psxVM,protfolioViewModel: portfolioVM,psxVM: psxVM,socketManager: socketManager)
                .presentationDetents([.large])
        }
        .task {
            await psxVM.getAllSymbols()
            await socketManager.getRealTimeTickersUpdate()
        }
        
    }
}

struct SheetView: View {
    
   @Binding var psxViewModel:PsxViewModel
    var protfolioViewModel:PortfolioViewModel
    var psxVM: PsxViewModel
    var socketManager:WebSocketManager
    
    
    var body: some View {
        NavigationView {
            VStack{
                switch psxViewModel.psxSearch {
                case .initial:
                    ProgressView()
                case .loading:
                    ProgressView()
                case .allSymbolLoaded(let allSymbol):
                    TickerListView(tickers: allSymbol,protfolioViewModel: protfolioViewModel,psxVM: psxVM,socketManager: socketManager)
                case .loaded(let data):
                    TickerListView(tickers: data,protfolioViewModel: protfolioViewModel,psxVM: psxVM,socketManager: socketManager)
                case .error(let errorMessage):
                    Text(errorMessage)
                }
            }
            .onChange(of: psxViewModel.symbolSearch, { oldValue, newValue in
                Task {
                    await psxViewModel.getFilteredSymbols()
                }
            })
            .searchable(text: $psxViewModel.symbolSearch,prompt: "Enter ticker")
            .navigationTitle("Symbol")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct TickerListView: View {
    
    var tickers:[String]
    var protfolioViewModel:PortfolioViewModel
    var psxVM:PsxViewModel
    var socketManager:WebSocketManager
    
    
    var body: some View {
        List(tickers,id: \.self){results in
            
            HStack{
                Text(results)
                Spacer()
                Image(systemName:  protfolioViewModel.savedTicker.contains(where: {$0.ticker == results}) ? "star.fill": "star")
            }
            .contentMargins(.top,0)
            .onTapGesture {
                protfolioViewModel.addTicker(ticker: results)
                Task{
                    try await Task.sleep(for: .seconds(3))
                    await psxVM.getPortfolioData()
                    await socketManager.getRealTimeTickersUpdate()
                }
                
            }
        }
    }
}


