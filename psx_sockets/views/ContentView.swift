//
//  ContentView.swift
//  psx_sockets
//
//  Created by sarim khan on 18/07/2025.
//

import SwiftUI



struct ContentView: View {
    
    
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
                
                
                // Corporate Actions Detail Views
                CorporateActionsSection(psxViewModel: psxViewModel,appNavigation: appNavigation)
                
                
                
                
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
            if webSocketManager.portfolioUpdate.isEmpty{
                await webSocketManager.getMarketUpdate(tickers: ["KSE100","ALLSHR","KMI30","PSXDIV20","KSE30","MII30"], market: "IDX")
            }
            
            if case DividendEnums.initial = psxViewModel.dividendEnums{
                await psxViewModel.getDividendData()

            }
        }
    }
    
    // Helper function to count actions
    private func getActionCount(data: [DividendModel], filter: (DividendModel) -> Bool) -> Int {
        guard case .loaded(let loadedData) = psxViewModel.dividendEnums else { return 0 }
        return loadedData.filter(filter).count
    }
}

struct TileView: View {
    var ticker: Top
    var body: some View {
        HStack(spacing: 12) {
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
                
                HStack(spacing: 8) {
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


// Corporate Action Card Component
struct CorporateActionCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// Main Corporate Actions Section
struct CorporateActionsSection: View {
    var psxViewModel: PsxViewModel
    var appNavigation: AppNavigation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch psxViewModel.dividendEnums {
            case .initial:
                ProgressView("Loading corporate actions...")
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .foregroundColor(.secondary)
                
            case .loading:
                ProgressView("Loading corporate actions...")
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .foregroundColor(.secondary)
                
            case .loaded(let data):
                LazyVStack(spacing: 16) {
                    // Only show sections that have data
                    if data.contains(where: { $0.dividend != "-" }) {
                        let dividendData = data.filter { $0.dividend != "-" }
                        DividendSection(data: Array(dividendData.prefix(3))) {
                            appNavigation.tickerNavigation.append(TickerDetailRoute.corporationDetail(sectionName: .Dividend, data: data))
                        }
                    }
                    
                    if data.contains(where: { $0.eps != "-" }) {
                        let epsData = data.filter { $0.eps != "-" }
                        EpsSection(data: Array(epsData.prefix(3))) {
                            appNavigation.tickerNavigation.append(TickerDetailRoute.corporationDetail(sectionName: .Eps, data: data))
                        }
                    }
                    
                    if data.contains(where: { $0.profitLossAfterTax != "-" || $0.profitLossBeforeTax != "-" }) {
                        let profitLossData = data.filter { $0.profitLossAfterTax != "-" || $0.profitLossBeforeTax != "-" }
                        ProfitLossSection(data: Array(profitLossData.prefix(3))) {
                            appNavigation.tickerNavigation.append(TickerDetailRoute.corporationDetail(sectionName: .ProfitLoss, data: data))
                        }
                    }
                    
                    if data.contains(where: { $0.boardMeeting != "-" }) {
                        let meetingData = data.filter { $0.boardMeeting != "-" }
                        MeetingSection(data: Array(meetingData.prefix(3))) {
                            appNavigation.tickerNavigation.append(TickerDetailRoute.corporationDetail(sectionName: .Meeting, data: data))
                        }
                    }
                }
                
            case .error(let errorMessage):
                ErrorView(message: errorMessage)
            }
        }
        .padding(.horizontal, 16)
    }
}

// Improved Dividend View
struct DividendSection: View {
    let data: [DividendModel]
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Dividend Announcements", icon: "gift", color: .green,corporationEnum: .Dividend,onTap: {
                
            })
                .onTapGesture(perform: onTap)
            
            ForEach(data.filter { $0.dividend != "-" }, id: \.id) { result in
                DividendCard(result: result)
            }
        }
    }
}

struct DividendCard: View {
    let result: DividendModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Company Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "gift")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(result.company)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text("Dividend:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(result.dividend)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                if result.date != "-" {
                    HStack {
                        Text("Payment:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.date)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
        }
        
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// Improved EPS View
struct EpsSection: View {
    let data: [DividendModel]
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "EPS Announcements", icon: "chart.line.uptrend.xyaxis", color: .orange,corporationEnum: .Eps,onTap: {})
                .onTapGesture(perform: onTap)
            
            ForEach(data.filter { $0.eps != "-" }, id: \.id) { result in
                EpsCard(result: result)
            }
        }
    }
}

struct EpsCard: View {
    let result: DividendModel
    
    private var isPositive: Bool {
        !result.eps.contains("(") && result.eps != "-"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isPositive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 18))
                    .foregroundColor(isPositive ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(result.company)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text("EPS:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(result.eps)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(isPositive ? .green : .red)
                }
                
                if result.yearEnded != "-" {
                    HStack {
                        Text("Period:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.yearEnded)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// Improved Profit/Loss View
struct ProfitLossSection: View {
    let data: [DividendModel]
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Profit & Loss", icon: "dollarsign.circle", color: .purple,corporationEnum: .ProfitLoss,onTap: {})
                .onTapGesture(perform: onTap)
            
            ForEach(data.filter { $0.profitLossAfterTax != "-" || $0.profitLossBeforeTax != "-" }, id: \.id) { result in
                ProfitLossCard(result: result)
            }
        }
    }
}

struct ProfitLossCard: View {
    let result: DividendModel
    
    private var isProfit: Bool {
        !result.profitLossAfterTax.contains("(") && result.profitLossAfterTax != "-"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isProfit ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: isProfit ? "plus.circle" : "minus.circle")
                    .font(.system(size: 18))
                    .foregroundColor(isProfit ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(result.company)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if result.profitLossAfterTax != "-" {
                    HStack {
                        Text("After Tax:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.profitLossAfterTax)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(isProfit ? .green : .red)
                    }
                }
                
                if result.profitLossBeforeTax != "-" {
                    HStack {
                        Text("Before Tax:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.profitLossBeforeTax)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(isProfit ? .green : .red)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// Improved Meeting View
struct MeetingSection: View {
    let data: [DividendModel]
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Board Meetings", icon: "person.2", color: .blue,corporationEnum: .Meeting,onTap: {})
                .onTapGesture(perform: onTap)
            
            ForEach(data.filter { $0.boardMeeting != "-" }, id: \.id) { result in
                MeetingCard(result: result)
            }
        }
    }
}

struct MeetingCard: View {
    let result: DividendModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "person.2")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(result.company)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text("Meeting:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(result.boardMeeting)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// Reusable Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    let corporationEnum:CorporationEnum
    let onTap: () -> Void
    let isFromDetail:Bool = false
    
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            

            Button(action: onTap) {
                Text("View all")
                    .font(.caption)
                    .foregroundColor(color)
            }
            .opacity(isFromDetail ? 0 : 1)
            .disabled(isFromDetail)

        }
    }
}


#Preview {
    ContentView()
}
