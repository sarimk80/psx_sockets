//
//  PortfolioView.swift
//  psx_sockets
//
//  Created by sarim khan on 10/09/2025.
//

import SwiftUI
import Charts

struct PortfolioView: View {
    
    @State private var showSymbolsheet = false
    @State private var psxVM: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var portfolioVM = PortfolioViewModel()
    @Environment(PortfolioNavigation.self) private var appNavigation
    @Environment(WebSocketManager.self) private var socketManager
    
    @State private var timer:Timer?
    @State private var sheetNavigation:SheetNavigation = SheetNavigation()
    
    
    private var totalStockCount:Int{
        socketManager.portfolioUpdate.map{$0.tick.volume ?? 0}.reduce(0, +)
    }
    
    private var totalStockValue:Double{
        let stockPrice = socketManager.portfolioUpdate.map{$0.tick.c}
        let stockCount = socketManager.portfolioUpdate.map{$0.tick.volume ?? 0}
        
        let totalStockWorth = zip(stockPrice, stockCount).map{Double($1) * $0}
            .reduce(0, +)
        
        return totalStockWorth
    }
    
    
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
            NavigationStack(path:$sheetNavigation.sheetNav){
                SymbolSearchSheetView(
                    psxViewModel: $psxVM,
                    portfolioViewModel: portfolioVM,
                    socketManager: socketManager,
                    path: $sheetNavigation.sheetNav
                )
                .navigationDestination(for: SheetNavigationEnums.self, destination: { destination in
                    switch destination {
                    case .openVolumeSheet(let symbol, let volume):
                        
                        VolumeSheet(symbol: symbol) { value in
                            portfolioVM.addTicker(ticker: symbol,volume: value)
                            Task {
                                try await Task.sleep(for: .seconds(2))
                                await socketManager.getRealTimeTickersUpdate()
                            }
                        }
                        
                    }
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            
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
            
            if socketManager.portfolioUpdate.isEmpty{
                EmptyView()
            }else{
                Section {
                    Chart(socketManager.portfolioUpdate, id: \.symbol) { result in
                        SectorMark(
                            angle: .value("Holdings", result.tick.volume ?? 1),
                            innerRadius: .ratio(0.75),
                            angularInset: 1
                        )
                        .foregroundStyle(by: .value("Symbol", result.symbol))
                    }
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            if let plotFrame = chartProxy.plotFrame {
                                let frame = geometry[plotFrame]
                                
                                VStack(spacing: 4) {
                                    Text("Holdings")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(totalStockValue, format: .currency(code: "PKR"))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    
                                    Text("\(totalStockCount) Stocks")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                    .frame(height: 250)
                    
                }
            }
            // portfolio list
            Section {
                ForEach(socketManager.portfolioUpdate, id: \.symbol) { result in
                    PortfolioStockRow(result: result,isShowHolding: true)
                    
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appNavigation.push(route: PortfolioNavigationEnums.tickerDetail(symbol: result.symbol))
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .padding(.horizontal, 2)
                                .padding(.vertical, 4)
                        )
                    
                }
            }
            header: {
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
        .listStyle(.insetGrouped)
        .contentMargins(8.0, for: .automatic)
        .scrollContentBackground(.hidden)
    }
    
    private var gradientColors: [Color] {
        [.blue, .green, .orange, .purple, .red, .teal, .pink, .indigo, .mint, .yellow]
    }
}

struct PortfolioStockRow: View {
    let result: TickerUpdate
    var isShowHolding:Bool = false
    
    private var totalStock: Double {
        result.tick.c * Double(result.tick.volume ?? 0)
    }
    
    private var isPositive: Bool {
        result.tick.ch > 0
    }
    
    private var trendColor: Color {
        isPositive ? .green : .red
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Symbol badge - improved with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                trendColor.opacity(0.2),
                                trendColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                
                Text(result.symbol.prefix(3))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(trendColor)
            }
            
            // Main content
            VStack(alignment: .leading, spacing: 6) {
                // Stock symbol
                Text(result.symbol)
                    .font(.system(.headline, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Stock holdings info
                if (isShowHolding) {    HStack(spacing: 4) {
                    Text("\(result.tick.volume ?? 0)")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("×")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Text(result.tick.c, format: .number.precision(.fractionLength(2)))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                }else{
                    Text(result.tick.sectorName ?? "")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right side - values and changes
            VStack(alignment: .trailing, spacing: 8) {
                // Total value
                Text(totalStock,format: .number)
                    .font(.system(.body, design: .monospaced, weight: .semibold))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                
                // Change indicators - more compact
                HStack(spacing: 6) {
                    // Percentage change pill
                    Text("\(result.tick.pch > 0 ? "+" : "")\(result.tick.pch, specifier: "%.2f")%")
                        .font(.system(.caption2, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(trendColor.opacity(0.12))
                        )
                    
                    // Arrow indicator
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                        .foregroundColor(trendColor)
                        .background(
                            Circle()
                                .fill(trendColor.opacity(0.1))
                        )
                    
                    // Absolute change
                    Text(result.tick.ch, format: .number.precision(.fractionLength(2)))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 4)
    }
}

struct SymbolSearchSheetView: View {
    @Binding var psxViewModel: PsxViewModel
    var portfolioViewModel: PortfolioViewModel
    var socketManager: WebSocketManager
    @Environment(\.dismiss) private var dismiss
    @Binding var path:NavigationPath
    
    var body: some View {
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
                    path: $path,
                    onDismiss: {dismiss()}
                )
                
            case .loaded(let data):
                SymbolListView(
                    symbols: data,
                    portfolioViewModel: portfolioViewModel,
                    psxViewModel: psxViewModel,
                    socketManager: socketManager,
                    path: $path,
                    onDismiss: {dismiss()}
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
    @Binding var path:NavigationPath
    let onDismiss: () -> Void
    
    @Environment(PortfolioNavigation.self) private var appNavigation
    
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
                            // check is symbol exist -- important
                            if(portfolioViewModel.savedTicker.contains{$0.ticker == symbol}){
                                portfolioViewModel.addTicker(ticker: symbol,volume: 0)
                                onDismiss()
                            }else{
                                path.append(SheetNavigationEnums.openVolumeSheet(symbol: symbol, volume: 0))
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
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct VolumeSheet: View {
    let symbol: String
    let onSubmit: (Int) -> Void
    
    @State private var volume: String = ""
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 4) {
                Text("Add Shares")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(symbol)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 16)
            
            // Input section
            VStack(spacing: 12) {
                HStack {
                    Text("Quantity:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let parsedVolume = Int(volume), parsedVolume > 0 {
                        Text("× \(parsedVolume)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                TextField("Enter number of shares", text: $volume)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .onAppear { isFocused = true }
            }
            
            Divider()
            
            // Quick actions
            Text("Quick add")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                QuickAddButton(value: 10, current: $volume)
                QuickAddButton(value: 50, current: $volume)
                QuickAddButton(value: 100, current: $volume)
                QuickAddButton(value: 500, current: $volume)
            }
            
            Spacer()
            
            // Submit button
            Button(action: submit) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Add to Portfolio")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canSubmit ? Color.blue : Color.gray)
                )
            }
            .disabled(!canSubmit)
            .animation(.easeInOut, value: canSubmit)
        }
        .padding()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private var canSubmit: Bool {
        guard let value = Int(volume.trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        return value > 0
    }
    
    private func submit() {
        if let value = Int(volume.trimmingCharacters(in: .whitespaces)), value > 0 {
            onSubmit(value)
            dismiss()
            dismiss()
        }
    }
}

struct QuickAddButton: View {
    let value: Int
    @Binding var current: String
    
    var body: some View {
        Button(action: { current = "\(value)" }) {
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
                .foregroundColor(.blue)
        }
    }
}


#Preview {
    NavigationView {
        PortfolioView()
    }
}
