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
    
    var body: some View {
        VStack{
            List(portfolioVM.savedTicker,id: \.id){data in
                    
                Text(data.ticker)
                
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
            SheetView(psxViewModel: $psxVM,protfolioViewModel: portfolioVM)
                .presentationDetents([.large])
        }
        .task {
            await psxVM.getAllSymbols()
        }
    }
}

struct SheetView: View {
    
   @Binding var psxViewModel:PsxViewModel
    var protfolioViewModel:PortfolioViewModel
    
    var body: some View {
        NavigationView {
            VStack{
                switch psxViewModel.psxSearch {
                case .initial:
                    ProgressView()
                case .loading:
                    ProgressView()
                case .allSymbolLoaded(let allSymbol):
                    TickerListView(tickers: allSymbol,protfolioViewModel: protfolioViewModel)
                case .loaded(let data):
                    TickerListView(tickers: data,protfolioViewModel: protfolioViewModel)
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
            }
        }
    }
}







#Preview {
    PortfolioView()
}
