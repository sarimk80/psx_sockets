//
//  PortfolioView.swift
//  psx_sockets
//
//  Created by sarim khan on 10/09/2025.
//

import SwiftUI
import Charts

struct SheetSymbol:Identifiable {
    let symbol:String
    let id = UUID()
}

struct PortfolioView: View {
    
    @State private var showSymbolsheet = false
    @State private var showVolumeSheet = false
    @State private var showDetailSheet = false
    @State private var selectedSymbol : SheetSymbol?
    @State private var psxVM: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var portfolioVM = PortfolioViewModel()
    @Environment(PortfolioNavigation.self) private var appNavigation
    @Environment(WebSocketManager.self) private var socketManager
    
    @State private var timer:Timer?
    @State private var sheetNavigation:SheetNavigation = SheetNavigation()
    
    
    
    
    
    
    var body: some View {
        VStack {
            portfolioListView
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
                    case .openVolumeSheet(let symbol, _):
                        
                        VolumeSheet(symbol: symbol, onSubmit: { volume, date,selectedSymbol, _ , price in
                            portfolioVM.addTicker(ticker: selectedSymbol,volume: volume,data: date.ISO8601Format(),price: price)
                            Task {
                                try await Task.sleep(for: .seconds(2))
                                await psxVM.getPortfolioSymbolDetail()
                            }
                        }, portfolioModel: portfolioVM.savedTicker,psxVM: psxVM,isOnlyVolume: false)
                        
                        
                        
                    }
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            
        }
        .task {
            if case PsxSearchSymbolEnum.initial = psxVM.psxSearch{
                await psxVM.getAllSymbols()
            }
            
            if case PortfolioTickerEnum.initial = psxVM.portfolioEnums{
                await psxVM.getPortfolioSymbolDetail()
            }
            
            stopTimer()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .refreshable {
            await psxVM.getPortfolioSymbolDetail()
        }
    }
    
    func stopTimer()  {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { _ in
            Task {
                await psxVM.getPortfolioSymbolDetail()
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
            
            switch psxVM.portfolioEnums {
            case .initial, .loading:
                Section {
                    ChartLoading()
                }
                
                Section {
                    ForEach(0..<6) { _ in
                        PortfolioStockRow(result: SymbolDataClass.mock, isShowHolding: true)
                            .redacted(reason: .placeholder)
                    }
                }
                
                
            case .loaded(let data):
                
                if (data.isEmpty){
                    emptyPortfolioView
                }else{
                    
                    
                    var totalStockCount:Int{
                        data.map{$0.data.portfolioVolume ?? 0}.reduce(0, +)
                    }
                    
                    var totalStockValue:Double{
                        let stockPrice = data.map{$0.data.price}
                        let stockCount = data.map{$0.data.portfolioVolume ?? 0}
                        
                        let totalStockWorth = zip(stockPrice, stockCount).map{Double($1) * $0}
                            .reduce(0, +)
                        
                        return totalStockWorth
                    }
                    
                    Section {
                        Chart(data, id: \.data.symbol) { result in
                            SectorMark(
                                angle: .value("Holdings", result.data.portfolioVolume ?? 1),
                                innerRadius: .ratio(0.75),
                                angularInset: 1
                            )
                            .foregroundStyle(by: .value("Symbol", result.data.symbol))
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
                                            .contentTransition(.numericText())
                                        
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
                    
                    
                    // portfolio list
                    Section {
                        ForEach(data, id: \.data.symbol) { result in
                            PortfolioStockRow(result: result.data,isShowHolding: true)
                            
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSymbol = SheetSymbol(symbol: result.data.symbol)
                                }
                                .listRowInsets(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
                            
                        }
                    }
                    header: {
                        HStack{
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Holdings")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(data.count) stocks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Button {
                                showVolumeSheet.toggle()
                            } label: {
                                Label("Add Transaction", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(Color.accentColor)
                                    .background(
                                        Capsule()
                                            .fill(Color.accentColor.opacity(0.2))
                                    )
                            }
                            .buttonStyle(SpringButtonStyle())
                        }
                        
                        
                        .padding(.bottom, 8)
                    }
                }
            case .error(let errorMessage):
                ErrorView(message: errorMessage)
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
        .sheet(isPresented: $showVolumeSheet, content: {
            VolumeSheet(symbol: "", onSubmit: { volume, date,selectedSymbol,selectedPortfolio,price in
                portfolioVM.addTransaction(portfolio: selectedPortfolio!, volume: volume, date: date.ISO8601Format(),price: price)
                Task {
                    try await Task.sleep(for: .seconds(2))
                    await psxVM.getPortfolioSymbolDetail()
                }
            }, portfolioModel: portfolioVM.savedTicker,
                        psxVM: psxVM,isOnlyVolume: true)
        })
        .sheet(item: $selectedSymbol, content: { result in
            DetailSheet(selectedSymbol: result.symbol) {
                appNavigation.push(route: PortfolioNavigationEnums.tickerDetail(symbol: result.symbol))
                selectedSymbol = nil
            } onTransactionTap: {
                appNavigation.push(route: PortfolioNavigationEnums.tickerTransaction(symbol: result.symbol))
                selectedSymbol = nil
            }
            
        })
        .scrollContentBackground(.hidden)
    }
    
    private var gradientColors: [Color] {
        [.blue, .green, .orange, .purple, .red, .teal, .pink, .indigo, .mint, .yellow]
    }
}

struct PortfolioStockRow: View {
    let result: SymbolDataClass
    var isShowHolding:Bool = false
    
    private var totalStock: Double {
        result.price * Double(result.portfolioVolume ?? 0)
    }
    
    private var isPositive: Bool {
        result.change > 0
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
                    Text("\(result.portfolioVolume ?? 0)")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("×")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Text(result.price, format: .number.precision(.fractionLength(2)))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                }else{
                    Text(result.sectorName ?? "")
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
                    Text("\(result.change > 0 ? "+" : "")\(result.changePercent, specifier: "%.2f")%")
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
                    Text(result.changePercent, format: .number.precision(.fractionLength(2)))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemGroupedBackground))
//                //.shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
//        )
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
                            //                            if(portfolioViewModel.savedTicker.contains{$0.ticker == symbol}){
                            //                                portfolioViewModel.addTicker(ticker: symbol,volume: 0)
                            //                                onDismiss()
                            //                            }else{
                            path.append(SheetNavigationEnums.openVolumeSheet(symbol: symbol, volume: 0))
                            //}
                            
                            
                        },
                        onDelete: {
                            portfolioViewModel.deletePortfolio(ticker: symbol)
                            Task{
                                try await Task.sleep(for: .seconds(2))
                                await psxViewModel.getPortfolioSymbolDetail()
                            }
                            onDismiss()
                        },
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.tertiarySystemBackground))
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
    let onDelete: () -> Void
    
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
                isInPortfolio ? onDelete() : onAdd()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isInPortfolio ? "trash" : "plus.circle.fill")
                        .font(.body)
                    
                    Text(isInPortfolio ? "Delete" : "Add")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(isInPortfolio ? .red : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill((isInPortfolio ? Color.red : Color.blue).opacity(0.1))
                )
            }
            
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct VolumeSheet: View {
    let symbol: String
    let onSubmit: (Int,Date,String,PortfolioModel?,Double) -> Void
    let portfolioModel:[PortfolioModel]
    let psxVM: PsxViewModel
    let isOnlyVolume: Bool
    
    @State private var volume: String = ""
    @State private var tickerPrice:Double = 0.0
    @State private var selectedDate: Date = Date()
    @FocusState private var isFocused: Bool
    @FocusState private var isPriceFocus: Bool
    @State private var transactionType: String = "Buy"
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSymbol: String = ""
    @State private var selectedPortfolioModel:PortfolioModel?
    
    
    var portfolioSymbol:[String]{
        portfolioModel.map({$0.ticker})
    }
    
    var sellError: Bool {
        guard transactionType == "Sell",
              let qty = Int(volume),
              let owned = selectedPortfolioModel?.volume else { return false }
        
        return qty > owned
    }
    
    
    var body: some View {
        
        
        Form {
            
            if isOnlyVolume {
                Section {
                    HStack {
                        
                        // Close button (left aligned)
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .glassEffect()
                        
                        Spacer()
                        
                        // Title (perfectly centered)
                        VStack(spacing: 2) {
                            Text(transactionType == "Buy" ? "Buy Shares" : "Sell Shares")
                                .font(.headline)
                            
                            Text(selectedSymbol)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Spacer to balance close button width
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            if symbol.isEmpty {
                
                Section("Trades") {
                    Picker("Status", selection: $transactionType) {
                        Text("Buy").tag("Buy")
                        Text("Sell").tag("Sell")
                    }
                    
                    Picker("Select Symbol", selection: $selectedSymbol) {
                        ForEach(portfolioSymbol, id: \.self) { ticker in
                            Text(ticker).tag(ticker)
                        }
                    }
                }
            }
            
            
            
            Section {
                TextField("Enter number of shares", text: $volume)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                    .animation(.spring(response: 0.25), value: volume.isEmpty)
                
                if sellError {
                    
                    Text("Volume cannot exceed available shares")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                                
                HStack(spacing: 12) {
                    QuickAddButton(value: 10, current: $volume)
                    QuickAddButton(value: 50, current: $volume)
                    QuickAddButton(value: 100, current: $volume)
                    QuickAddButton(value: 200, current: $volume)
                    QuickAddButton(value: 500, current: $volume)
                }
                
                
                
            } header: {
                HStack {
                    Text("Quantity:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let qty = Int(volume), qty > 0 {
                        Text("Total: \((Double(qty) * tickerPrice), format: .currency(code: "PKR"))")
                            .font(.headline)
                            .foregroundStyle(transactionType == "Buy" ? .green : .red)
                    }
                }
            }
            
            
            
            Section("Price") {
                // Price
                switch psxVM.tickerPriceEnum {
                case .initial:
                    ProgressView()
                case .loading:
                    ProgressView()
                case .loaded(let tickerResponse):
                    let price = tickerResponse.data.first?.price ?? 0.0
                    
                    let step:Double = 0.5
                    
                    let stepperRange = (price - 10)...(price + 10)
                    
                    TextField("Enter Price", value: $tickerPrice,format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($isPriceFocus)
//                        .onAppear{
//                            tickerPrice = price
//                        }
                        .animation(.easeInOut(duration: 0.2), value: isPriceFocus)
                        .animation(.spring(response: 0.25), value: volume.isEmpty)
                    
                    
                    Stepper("Adjust price", value: $tickerPrice, in: stepperRange,step:step)
                    
                    
                case .error(let errorMessage):
                    Text(errorMessage)
                }
            }
            
            
            Section("Date") {
                DatePicker(
                    "Transaction Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
            }
            
            
            Section{
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
                            .fill(canSubmit
                                  ? (transactionType == "Buy" ? Color.green : Color.red)
                                  : Color.gray.opacity(0.3)
                                 )
                    )
                }
                .disabled(!canSubmit)
                .animation(.easeInOut, value: canSubmit)
            }
            .listRowBackground(Color(.clear))
            
        }
        .navigationTitle(transactionType == "Buy" ? "Buy Shares" : "Sell Shares")
        .navigationSubtitle(selectedSymbol)
        .navigationBarTitleDisplayMode(.inline)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if !symbol.isEmpty {
                selectedSymbol = symbol
                
            } else {
                selectedSymbol = portfolioSymbol.first ?? ""
                selectedPortfolioModel = portfolioModel.first(where: {$0.ticker == selectedSymbol})
                
            }
            Task{
                await psxVM.getTickerPrice(ticker: selectedSymbol)
            }
        }
        .onChange(of: selectedSymbol) { _, newValue in
            Task{
                await psxVM.getTickerPrice(ticker: newValue)
                selectedPortfolioModel = portfolioModel.first(where: {$0.ticker == newValue})
            }
        }
        .onChange(of: psxVM.tickerPriceEnum) { _, newValue in
            if case .loaded(let tickerResponse) = newValue {
                tickerPrice = tickerResponse.data.first?.price ?? 0.0
            }
        }
    }
    
    private var canSubmit: Bool {
        guard let value = Int(volume.trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        return value > 0
    }
    
    private func submit() {
        if let value = Int(volume.trimmingCharacters(in: .whitespaces)), value > 0 {
            onSubmit(value,selectedDate,selectedSymbol,selectedPortfolioModel,tickerPrice)
            dismiss()
            dismiss()
        }
    }
}

struct PriveView: View {
    let price: Double
    var body: some View{
        
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
        .buttonStyle(.plain)
    }
}

struct DetailSheet: View {
    var selectedSymbol: String = ""
    var onDetailTap: () -> Void
    var onTransactionTap: () -> Void
    
    
    var body: some View{
        VStack(spacing: 24) {
            
            // Drag indicator (common in sheets)
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            VStack(spacing: 6) {
                Text("Explore \(selectedSymbol)")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Select what you would like to view")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 14) {
                
                Button {
                    onDetailTap()
                } label:{
                    HStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 42, height: 42)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Ticker details")
                                .font(.headline)
                            
                            Text("View price info, market data and metrics")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(SpringButtonStyle())
                
                
                
                Button {
                    onTransactionTap()
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.title3)
                            .foregroundColor(.green)
                            .frame(width: 42, height: 42)
                            .background(Color.green.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Transaction history")
                                .font(.headline)
                            
                            Text("View past trades and activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                }
                .buttonStyle(SpringButtonStyle())
                
                
                
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .presentationDetents([.height(330)])
    }
    
}


#Preview {
    NavigationView {
        PortfolioView()
    }
}
