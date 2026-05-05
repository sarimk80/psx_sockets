//
//  SearchView.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import SwiftUI

struct SearchView: View {
    
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Binding var moreNavigation: MoreNavigation
        
    var body: some View {
        List {
            switch psxViewModel.psxSearch {
            case .initial, .loading:
                ProgressView()
                
            case .loaded(let data):
                ForEach(data, id: \.self) { result in
                    Text(result)
                        .onTapGesture {
                            moreNavigation.push(route: .tickerDetail(symbol: result))
                        }
                }
                
            case .allSymbolLoaded(let allSymbol):
                ForEach(allSymbol, id: \.self) { result in
                    Text(result)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            moreNavigation.push(route: .tickerDetail(symbol: result))
                        }
                }
                
            case .error(let message):
                Text(message)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $psxViewModel.symbolSearch,
                    prompt: "Enter ticker here...")
        .onChange(of: psxViewModel.symbolSearch) { _, _ in
            Task {
                await psxViewModel.getFilteredSymbols()
            }
        }
        .task {
            await psxViewModel.getAllSymbols()
        }
    }
}

