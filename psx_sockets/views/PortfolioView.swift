//
//  PortfolioView.swift
//  psx_sockets
//
//  Created by sarim khan on 10/09/2025.
//

import SwiftUI

struct PortfolioView: View {
    
    @State private var showSymbolsheet = false
    @State private var psxVM: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var portfolioVM = PortfolioViewModel()
    @Environment(AppNavigation.self) private var appNavigation
    @Environment(WebSocketManager.self) private var socketManager
    @State private var timer:Timer?
    
    var body: some View {
        VStack {
            if socketManager.isLoading {
                ProgressView()
            } else {
                portfolioListView
            }
        }
        
        .background(Color(.systemGroupedBackground))
        
        .sheet(isPresented: $showSymbolsheet) {
            SymbolSearchSheetView(
                psxViewModel: $psxVM,
                portfolioViewModel: portfolioVM,
                socketManager: socketManager
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            await psxVM.getAllSymbols()
            await socketManager.getRealTimeTickersUpdate()
            stopTimer()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func stopTimer()  {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 40, repeats: true) { _ in
            Task {
                await socketManager.getRealTimeTickersUpdate()
            }
        }
    }
    
    private var emptyPortfolioView: some View {
        VStack(spacing: 24) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 70))
                .foregroundColor(.secondary)
                .padding()
            
            VStack(spacing: 12) {
                Text("No Stocks in Portfolio")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Add stocks to your portfolio to track their performance")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                showSymbolsheet.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Stock")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var portfolioListView: some View {
        List {
            Section {
                ForEach(socketManager.portfolioUpdate, id: \.symbol) { result in
                    PortfolioStockRow(result: result)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: result.symbol))
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        )
                }
            } header: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Holdings")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(socketManager.portfolioUpdate.count) stocks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Symbol", systemImage: "plus.circle.fill") {
                    self.showSymbolsheet.toggle()
                }
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct PortfolioStockRow: View {
    let result: TickerUpdate
    
    var body: some View {
        HStack(spacing: 16) {
            // Symbol with colored background
            ZStack {
                Circle()
                    .fill(result.tick.ch > 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(result.symbol.prefix(3))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(result.tick.ch > 0 ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.symbol)
                    .font(.headline)
                    .foregroundColor(.primary)
                
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(result.tick.c, format: .number.precision(.fractionLength(2)))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                
                HStack(spacing: 8) {
                    Image(systemName: result.tick.ch > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                        .foregroundColor(result.tick.ch > 0 ? .green : .red)
                    
                    Text(result.tick.ch, format: .number.precision(.fractionLength(2)))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(result.tick.ch > 0 ? .green : .red)
                    
                    Text("\(result.tick.pch > 0 ? "+" : "")\(String(format: "%.2f", result.tick.pch))%")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(result.tick.ch > 0 ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill((result.tick.ch > 0 ? Color.green : Color.red).opacity(0.1))
                        )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SymbolSearchSheetView: View {
    @Binding var psxViewModel: PsxViewModel
    var portfolioViewModel: PortfolioViewModel
    var socketManager: WebSocketManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                switch psxViewModel.psxSearch {
                case .initial:
                    ProgressView("Loading symbols...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .loading:
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .allSymbolLoaded(let allSymbol):
                    SymbolListView(
                        symbols: allSymbol,
                        portfolioViewModel: portfolioViewModel,
                        psxViewModel: psxViewModel,
                        socketManager: socketManager,
                        onDismiss: { dismiss() }
                    )
                    
                case .loaded(let data):
                    SymbolListView(
                        symbols: data,
                        portfolioViewModel: portfolioViewModel,
                        psxViewModel: psxViewModel,
                        socketManager: socketManager,
                        onDismiss: { dismiss() }
                    )
                    
                case .error(let errorMessage):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Symbols")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Add Symbols")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role:.cancel) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .searchable(
            text: $psxViewModel.symbolSearch,
            prompt: "Search for stock symbols..."
        )
        .onChange(of: psxViewModel.symbolSearch) { oldValue, newValue in
            Task {
                await psxViewModel.getFilteredSymbols()
            }
        }
    }
}

struct SymbolListView: View {
    let symbols: [String]
    let portfolioViewModel: PortfolioViewModel
    let psxViewModel: PsxViewModel
    let socketManager: WebSocketManager
    let onDismiss: () -> Void
    
    var body: some View {
        List {
            if symbols.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Symbols Found")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Try searching for a different symbol")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .listRowSeparator(.hidden)
            } else {
                ForEach(symbols, id: \.self) { symbol in
                    SymbolRow(
                        symbol: symbol,
                        isInPortfolio: portfolioViewModel.savedTicker.contains { $0.ticker == symbol },
                        onAdd: {
                            portfolioViewModel.addTicker(ticker: symbol)
                            Task {
                                try await Task.sleep(for: .seconds(2))
                                await socketManager.getRealTimeTickersUpdate()
                                onDismiss()
                            }
                        }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    )
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct SymbolRow: View {
    let symbol: String
    let isInPortfolio: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Symbol badge
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(symbol.prefix(3))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(symbol)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Stock Symbol")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                onAdd()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isInPortfolio ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.body)
                    
                    Text(isInPortfolio ? "Added" : "Add")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(isInPortfolio ? .green : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill((isInPortfolio ? Color.green : Color.blue).opacity(0.1))
                )
            }
            .disabled(isInPortfolio)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationView {
        PortfolioView()
    }
}
