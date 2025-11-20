//
//  ContentView.swift
//  psx_sockets
//
//  Created by sarim khan on 18/07/2025.
//

import SwiftUI

enum StockerEnums: String, Identifiable {
    case Active
    case Lossers
    
    var id: Self { self }
}

struct ContentView: View {
    
    @State private var stockerEnums: StockerEnums = .Active
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Environment(AppNavigation.self) private var appNavigation
    @Environment(WebSocketManager.self) private var webSocketManager
    @State private var selectedTab: Int = 0
    
    var body: some View {
        List {
            VStack(spacing: 20) {
                // Index Carousel Section
                IndexView(psxWebSocket: webSocketManager, selectedTab: $selectedTab)
                
                // Custom Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        Capsule()
                            .fill(index == selectedTab ? Color("AccentColor") : Color.gray.opacity(0.3))
                            .frame(width: index == selectedTab ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: selectedTab)
                    }
                }
                .padding(.vertical, 8)
                
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
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .navigationTitle("Market Overview")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .task {
            await psxViewModel.getPsxMarketStats()
            await webSocketManager.getMarketUpdate(tickers: ["KSE100","ALLSHR","KMI30","PSXDIV20","KSE30","MII30"], market: "IDX")
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
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal, 16)
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

struct TileView: View {
    var ticker: Top
    var body: some View {
        HStack(spacing: 16) {
            // Symbol with background
            ZStack {
                Circle()
                    .fill(ticker.change > 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(ticker.symbol.prefix(3))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(ticker.change > 0 ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ticker.symbol)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(ticker.price, format: .number.precision(.fractionLength(2)))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: ticker.change > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                            .foregroundColor(ticker.change > 0 ? .green : .red)
                        
                        Text(ticker.change, format: .number.precision(.fractionLength(2)))
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(ticker.change > 0 ? .green : .red)
                    }
                    
                    Text(ticker.changePercent, format: .number.precision(.fractionLength(2)))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(ticker.change > 0 ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill((ticker.change > 0 ? Color.green : Color.red).opacity(0.1))
                        )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatsView: View {
    var psxViewModel: PsxViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch psxViewModel.psxStats {
            case .initial:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case .loaded(let data):
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(title: "Gainers", value: "\(data.data.gainers)", color: .green)
                    StatCard(title: "Losers", value: "\(data.data.losers)", color: .red)
                    StatCard(title: "Total Trades", value: "\(data.data.totalTrades)", color: .blue)
                    StatCard(title: "Total Volume", value: "\(data.data.totalVolume)", color: .orange)
                }
            case .error(let errorMessage):
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct IndexView: View {
    var psxWebSocket: WebSocketManager
    @Binding var selectedTab: Int
    
    var body: some View {
        if psxWebSocket.portfolioUpdate.isEmpty {
            ProgressView("Loading indices...")
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)
        } else {
            TabView(selection: $selectedTab) {
                ForEach(psxWebSocket.portfolioUpdate.enumerated(), id: \.element) { index, result in
                    TickerView(ticker: result)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(.systemBackground), Color(.systemGray6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 16)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .frame(height: 180)
        }
    }
}

struct TickerView: View {
    var ticker: TickerUpdate?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticker?.symbol ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(ticker?.tick.st ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }
                
                Spacer()
                
                // Current Price with change indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text(ticker?.tick.c ?? 0.0, format: .number.precision(.fractionLength(2)))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                    
                    if let change = ticker?.tick.ch {
                        HStack(spacing: 4) {
                            Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption2)
                            
                            Text(change, format: .number.precision(.fractionLength(2)))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(change > 0 ? .green : .red)
                    }
                }
            }
            
            // Price metrics
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    priceMetric(title: "Open", value: ticker?.tick.o ?? 0.0)
                    priceMetric(title: "High", value: ticker?.tick.h ?? 0.0)
                    priceMetric(title: "Low", value: ticker?.tick.l ?? 0.0)
                }
                
                Spacer()
                
                if ticker?.market != "IDX" {
                    VStack(alignment: .trailing, spacing: 6) {
                        priceMetric(title: "Bid", value: ticker?.tick.bp ?? 0.0)
                        priceMetric(title: "Bid Vol", value: Double(ticker?.tick.bv ?? 0))
                        priceMetric(title: "Ask", value: ticker?.tick.ap ?? 0.0)
                        priceMetric(title: "Ask Vol", value: Double(ticker?.tick.av ?? 0))
                    }
                }
            }
            .font(.caption)
        }
        .padding()
    }
    
    private func priceMetric(title: String, value: Double) -> some View {
        HStack {
            if title.contains("Bid") || title.contains("Ask") {
                Spacer()
            }
            
            Text(title)
                .foregroundColor(.secondary)
            
            Text(value, format: .number.precision(.fractionLength(2)))
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            if !title.contains("Bid") && !title.contains("Ask") {
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
