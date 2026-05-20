//
//  CircuitBreakerView.swift
//  psx_sockets
//
//  Created by sarim khan on 20/05/2026.
//

import SwiftUI

struct CircuitBreakerView: View {
    
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Environment(MoreNavigation.self) private var moreNavigation
    
    var body: some View {
        Group {
            switch psxViewModel.breakerEnum {
                
            case .initial, .loading:
                VStack {
                    Spacer()
                    ProgressView("Loading Circuit Breakers...")
                        .progressViewStyle(.circular)
                    Spacer()
                }
                
            case .loaded(let circuitBreaker):
                List {
                    
                    if !circuitBreaker.upper.isEmpty {
                        Section("Upper Circuit") {
                            ForEach(circuitBreaker.upper, id: \.id) { item in
                                CircuitBreakerRow(data: item, isUpper: true)
                                    .onTapGesture {
                                        moreNavigation.push(route: .tickerDetail(symbol: item.symbol))
                                    }
                            }
                        }
                    }
                    
                    if !circuitBreaker.lower.isEmpty {
                        Section("Lower Circuit") {
                            ForEach(circuitBreaker.lower, id: \.id) { item in
                                CircuitBreakerRow(data: item, isUpper: false)
                                    .onTapGesture {
                                        moreNavigation.push(route: .tickerDetail(symbol: item.symbol))
                                    }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await psxViewModel.getAllCircuitBreaker()
                }
                
            case .error(let message):
                ErrorView(message: message)
            }
        }
        .navigationTitle("Circuit Breaker")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await psxViewModel.getAllCircuitBreaker()
        }
    }
}

struct CircuitBreakerRow: View {
    
    let data: Lower
    let isUpper: Bool
    
    var body: some View {
        HStack {
            
            // Symbol + Volume
            VStack(alignment: .leading, spacing: 4) {
                Text(data.symbol)
                    .font(.headline)
                
                Text("Vol: \(data.volume)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f", data.current))
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Image(systemName: isUpper ? "arrow.up.right" : "arrow.down.right")
                    
                    Text(String(format: "%.2f%%", data.changePercent))
                }
                .font(.caption.bold())
                .foregroundStyle(isUpper ? .green : .red)
            }
        }
        .padding(.vertical, 6)
    }
}
