//  HotStocks.swift
//  psx_sockets
//
//  Created by sarim khan on 24/11/2025.
//

import SwiftUI

enum StockerEnums: String, Identifiable, CaseIterable {
    case Gainers
    case Losers
    case Active
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .Gainers: return "Gainers"
        case .Losers: return "Losers"
        case .Active: return "Most Active"
        }
    }
    
    var iconName: String {
        switch self {
        case .Gainers: return "chart.line.uptrend.xyaxis"
        case .Losers: return "chart.line.downtrend.xyaxis"
        case .Active: return "chart.bar.fill"
        }
    }
}

struct HotStocks: View {
    
    @State private var stockerEnums: StockerEnums = .Gainers
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Environment(AppNavigation.self) private var appNavigation
    @State private var isRefreshing = false
    
    var body: some View {
        List {
            // Header Section
            headerSection
            
            // Stats Cards Section
            //statsCardsSection
            
            // Stocks List Section
            stocksListSection
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Market Performance")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshData()
        }
        .task {
            await loadInitialData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        Section {
            VStack(spacing: 16) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hot Stocks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Top performing stocks in the market")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Segmented Control
                Picker("Market Performance", selection: $stockerEnums) {
                    ForEach(StockerEnums.allCases) { stockType in
                        Label(stockType.title, systemImage: stockType.iconName)
                            .tag(stockType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
            }
            .padding(.vertical, 8)
        }
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Stats Cards Section
    private var statsCardsSection: some View {
        Section {
            HStack(spacing: 12) {
                ForEach(StockerEnums.allCases, id: \.self) { stockType in
                    statsCard(for: stockType)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private func statsCard(for stockType: StockerEnums) -> some View {
        let isSelected = stockerEnums == stockType
        
        VStack(spacing: 8) {
            Image(systemName: stockType.iconName)
                .font(.title2)
                .foregroundColor(isSelected ? .white : stockType.color)
            
            Text(stockType.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? stockType.color : Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? stockType.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                stockerEnums = stockType
            }
        }
    }
    
    // MARK: - Stocks List Section
    private var stocksListSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Section Header
                HStack {
                    Text(stockerEnums.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if case .loaded(let gainers, let losers, let active) = psxViewModel.hotStockEnum {
                        let count: Int = {
                            switch stockerEnums {
                            case .Gainers: return gainers.count
                            case .Losers: return losers.count
                            case .Active: return active.count
                            }
                        }()
                        Text("\(count) stocks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
                
                // Content
                stocksListView
            }
            .padding(.vertical, 8)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var stocksListView: some View {
        switch psxViewModel.hotStockEnum {
        case .initial, .loading:
            loadingView
            
        case .loaded(let gainers, let losers, let active):
            let stocks: [SectorStocks] = {
                switch stockerEnums {
                case .Gainers: return gainers
                case .Losers: return losers
                case .Active: return active
                }
            }()
            
            if stocks.isEmpty {
                emptyStateView
            } else {
                ForEach(stocks, id: \.scriptName) { result in
                    StocksListView(sectorStock: result)
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                        )
                }
            }
            
        case .error(let errorMessage):
            errorStateView(message: errorMessage)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading market data...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: stockerEnums.iconName)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No \(stockerEnums.title.lowercased()) found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("There are currently no \(stockerEnums.title.lowercased()) in the market")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
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
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            Button("Try Again") {
                Task {
                    await refreshData()
                }
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Data Loading
    private func loadInitialData() async {
        await psxViewModel.getPsxMarketStats()
    }
    
    private func refreshData() async {
        isRefreshing = true
        await psxViewModel.getPsxMarketStats()
        isRefreshing = false
    }
}

// MARK: - Stocks List Item View
struct StocksListView: View {
    var sectorStock: SectorStocks
    
    var body: some View {
        HStack(spacing: 16) {
            // Stock Name
            VStack(alignment: .leading, spacing: 4) {
                Text(sectorStock.scriptName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("LTP: \(sectorStock.current)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Price Indicators
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("H: \(sectorStock.high)")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        Text("L: \(sectorStock.low)")
                            .font(.caption2)
                            .foregroundColor(.red)
                        
                        Text("O: \(sectorStock.open)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    // Change Indicator
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(sectorStock.change)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(changeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(changeColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        Text("Vol: \(sectorStock.volume)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private var changeColor: Color {
        if sectorStock.trend.lowercased() == "increase" {
            return .green
        } else if sectorStock.trend.lowercased() == "decrease" {
            return .red
        } else {
            return .gray
        }
    }
}

// MARK: - Extensions for Colors
extension StockerEnums {
    var color: Color {
        switch self {
        case .Gainers: return .green
        case .Losers: return .red
        case .Active: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        HotStocks()
    }
}
