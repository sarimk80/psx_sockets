//
//  TickerDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 28/08/2025.
//

import SwiftUI
import Charts

struct TickerDetailView: View {
    var symbol:String
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    @Environment(WebSocketManager.self) private var psxSocketManager
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing: 20){
                // Ticker Header
                if psxSocketManager.portfolioUpdate.isEmpty {
                    ProgressView()
                        .frame(height: 80)
                } else {
                    TickerView(ticker: psxSocketManager.portfolioUpdate.first)
                        .padding(.horizontal, 16)
                }
                
                // Chart Section
                KlineChart(psxSocketManager: psxSocketManager, psxViewModel: psxViewModel)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                
                // Company Details
                switch psxViewModel.psxCompany {
                case .initial:
                    ProgressView()
                        .frame(height: 200)
                case .loading:
                    ProgressView()
                        .frame(height: 200)
                case .loaded(let company, let dividend, let fundamental):
                    VStack(alignment:.leading, spacing: 24){
                        // About Section
                        DetailSection(title: "About") {
                            Text(company.data.businessDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        
                        // Fundamentals Section
                        DetailSection(title: "Fundamentals") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                CompanyFundamentals(title: "Free float:", subTitle: company.data.financialStats.freeFloat.raw)
                                CompanyFundamentals(title: "Free float %:", subTitle: company.data.financialStats.freeFloatPercent.raw)
                                CompanyFundamentals(title: "Market Cap:", subTitle: company.data.financialStats.marketCap.raw)
                                CompanyFundamentals(title: "Total shares:", subTitle: company.data.financialStats.shares.raw)
                                CompanyFundamentals(title: "Change %:", subTitle: fundamental.data.changePercent.formatted(.number.precision(.fractionLength(2))))
                                CompanyFundamentals(title: "Dividend Yield:", subTitle: fundamental.data.dividendYield.description)
                                CompanyFundamentals(title: "Sharia Compliant:", subTitle: fundamental.data.isNonCompliant.description)
                                CompanyFundamentals(title: "P/E ratio:", subTitle: fundamental.data.peRatio.formatted(.number.precision(.fractionLength(2))))
                                CompanyFundamentals(title: "Yearly Change:", subTitle: fundamental.data.yearChange.formatted(.number.precision(.fractionLength(2))))
                                CompanyFundamentals(title: "Volume Avg yearly:", subTitle: fundamental.data.volume30Avg.description)
                            }
                        }
                        
                        // Key People Section
                        DetailSection(title: "Key People") {
                            VStack(spacing: 12) {
                                ForEach(company.data.keyPeople, id: \.position) { person in
                                    HStack {
                                        Text(person.position)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(person.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    if person.position != company.data.keyPeople.last?.position {
                                        Divider()
                                    }
                                }
                            }
                        }
                        
                        // Dividend Section
                        DetailSection(title: "Dividend History") {
                            VStack(spacing: 12) {
                                // Header
                                HStack {
                                    Text("Symbol")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Payment Date")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    Text("Dividend")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                
                                // Dividend Rows
                                ForEach(dividend.data, id: \.paymentDate) { dividend in
                                    HStack {
                                        Text(dividend.symbol)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(dividend.paymentDate)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        Text(String(describing: dividend.amount))
                                            .font(.headline)
                                            .foregroundColor(.green)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                case .error(let errorMessage):
                    ErrorView(message: errorMessage)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await psxViewModel.getCompanyDetail(symbol: symbol)
            await psxSocketManager.getMarketUpdate(tickers: [symbol], market: "REG",inIndex: true)
            await psxViewModel.getKlineSymbol(symbol: symbol, timeFrame: "1d")
        }
    }
}

// MARK: - Supporting Views

struct DetailSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                )
        }
    }
}

struct CompanyFundamentals: View {
    var title: String
    var subTitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(subTitle)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error Loading Data")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
}

struct KlineChart: View {
    var psxSocketManager: WebSocketManager
    var psxViewModel: PsxViewModel
    
    @State private var scrollPosition: Date = .now
    
    var body: some View {
        ZStack {
            switch psxViewModel.kLineEnum {
            case .initial:
                ProgressView()
                    .frame(width: 200,height: 200)
            case .loading:
                ProgressView()
                    .frame(width:200,height: 200)
            case .loaded(let kline):
                KlineChartView(kline: kline, scrollPosition: $scrollPosition)
            case .error(let errorMessage):
                ErrorView(message: errorMessage)
            }
        }
    }
}

struct KlineChartView: View {
    var kline: KLineRequestModel
    @Binding var scrollPosition: Date
    
    var body: some View {
        let closes = kline.data.map { $0.close }
        let open = kline.data.map{ $0.datumOpen}
        let minClose = closes.min() ?? 0.0
        let maxClose = closes.max() ?? 0.0
        let lastDate = kline.data.last?.adjustedDate ?? .now
        
        let isPositive = closes.last ?? 0.0 >= open.last ?? 0.0
        let lineColor:Color = isPositive ? .green : .red
        
        Chart {
            ForEach(kline.data) { data in
                
                LineMark(x: .value("Date", data.adjustedDate), y: .value("Price", data.close))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, lineColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.cardinal)
                    .annotation(position:.top) {
                        Text("\(data.close)")
                            .foregroundStyle(.secondary)
                    }
                
                AreaMark(x: .value("Date", data.adjustedDate), y: .value("Price", data.close))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [lineColor.opacity(0.3), lineColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .chartYScale(domain: [minClose * 0.98, maxClose * 1.02])
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $scrollPosition)
        .chartXVisibleDomain(length: 60 * 60 * 24 * 30)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(doubleValue, format: .number.precision(.fractionLength(2)))
                    }
                }
            }
        }
        .frame(height: 350)
        .onAppear {
            self.scrollPosition = lastDate
        }
    }
}

#Preview {
    TickerDetailView(symbol: "DCR")
}
