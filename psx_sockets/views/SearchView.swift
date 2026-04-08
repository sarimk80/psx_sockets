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
        VStack{
            switch psxViewModel.psxSearch {
            case .initial:
                ProgressView()
            case .loading:
                ProgressView()
            case .loaded(let data):
                List(data,id: \.self){result in
                    Text(result)
                        .onTapGesture {
                            moreNavigation.push(route: .tickerDetail(symbol: result))
                        }
                    
                }
            case .error(let errorMessage):
                Text(errorMessage)
            case .allSymbolLoaded(allSymbol: let allSymbol):
                List(allSymbol,id: \.self){result in
                    Text(result)
                        .onTapGesture {
                            moreNavigation.push(route: .tickerDetail(symbol: result))
                        }
                    
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $psxViewModel.symbolSearch, prompt: "Enter ticker here...")
        .onChange(of: psxViewModel.symbolSearch, { oldValue, newValue in
            Task {
                await psxViewModel.getFilteredSymbols()
            }
        })
        
            .task {
               await psxViewModel.getAllSymbols()
            }

    }
}

