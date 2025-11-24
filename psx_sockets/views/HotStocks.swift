//
//  HotStocks.swift
//  psx_sockets
//
//  Created by sarim khan on 24/11/2025.
//

import SwiftUI

enum StockerEnums: String, Identifiable {
    case Active
    case Lossers
    
    var id: Self { self }
}

struct HotStocks: View {
    
    @State private var stockerEnums: StockerEnums = .Active
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Environment(AppNavigation.self) private var appNavigation
    
    var body: some View {
        List{
            // Segmented Control
            Picker("Market Performance", selection: $stockerEnums) {
                Text("Gainers").tag(StockerEnums.Active)
                Text("Losers").tag(StockerEnums.Lossers)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
            
            // Stocks List
            stocksListView
        }
        .navigationTitle("Hot Stocks")
        .listStyle(.plain)
        .task {
            await psxViewModel.getPsxMarketStats()
        }
       
       
    }
    
    @ViewBuilder
    private var stocksListView: some View {
        switch psxViewModel.psxStats {
        case .initial:
            ProgressView("Loading market data...")
                .frame(maxWidth: .infinity, minHeight: 200)
                .foregroundColor(.secondary)
            
        case .loading:
            ProgressView("Loading market data...")
                .frame(maxWidth: .infinity, minHeight: 200)
                .foregroundColor(.secondary)
            
        case .loaded(let data):
            let stocks = stockerEnums == .Active ? data.data.topGainers : data.data.topLosers
            
            if stocks.isEmpty {
                emptyStateView
            } else {
                ForEach(stocks, id: \.symbol) { ticker in
                    TileView(ticker: ticker)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .onTapGesture {
                            appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: ticker.symbol))
                        }
                }
            }
            
        case .error(let errorMessage):
            errorStateView(message: errorMessage)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No stocks found")
                .font(.headline)
                .foregroundColor(.primary)
            Text("There are currently no \(stockerEnums == .Active ? "gainers" : "losers") in the market")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
    
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Unable to load data")
                .font(.headline)
                .foregroundColor(.primary)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

#Preview {
    HotStocks()
}
