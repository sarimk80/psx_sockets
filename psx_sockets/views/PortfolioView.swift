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
    
    var body: some View {
        VStack{
            switch psxVM.portfolioData{
            case .initial:
                ProgressView()
            case .loading:
                ProgressView()
            case .error(let errorMessage):
                Text(errorMessage)
            case .loaded(let data):
                List(data,id: \.data.timestamp){result in
                    HStack{
                        Text(result.data.symbol)
                            .font(.subheadline)
                        Spacer()
                        VStack{
                            Text(result.data.price,format: .number.precision(.fractionLength(2)))
                                .font(.subheadline)
                            Text(result.data.changePercent,format: .number.precision(.fractionLength(2)))
                                .font(.caption)
                        }
                    }
                    .onTapGesture {
                        appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: result.data.symbol))
                    }
                    
                }
                
                
            }
                
            
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "rectangle.portrait.badge.plus") {
                    self.showSymbolsheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showSymbolsheet) {
            SheetView(psxViewModel: $psxVM,protfolioViewModel: portfolioVM,psxVM: psxVM)
                .presentationDetents([.large])
        }
        .task {
            await psxVM.getAllSymbols()
            await psxVM.getPortfolioData()
        }
        
    }
}

struct SheetView: View {
    
   @Binding var psxViewModel:PsxViewModel
    var protfolioViewModel:PortfolioViewModel
    var psxVM: PsxViewModel
    
    
    var body: some View {
        NavigationView {
            VStack{
                switch psxViewModel.psxSearch {
                case .initial:
                    ProgressView()
                case .loading:
                    ProgressView()
                case .allSymbolLoaded(let allSymbol):
                    TickerListView(tickers: allSymbol,protfolioViewModel: protfolioViewModel,psxVM: psxVM)
                case .loaded(let data):
                    TickerListView(tickers: data,protfolioViewModel: protfolioViewModel,psxVM: psxVM)
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
                }
                
            }
        }
    }
}


