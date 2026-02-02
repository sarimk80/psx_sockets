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
    
    @State private var companyOverview = CompanyOverviews.CompanyDetail
    
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
                    .padding(.vertical,8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                
                
                Picker("Picker", selection: $companyOverview) {
                    Text("Company Details").tag(CompanyOverviews.CompanyDetail)
                    Text("Financial Dashboard").tag(CompanyOverviews.CompanyFinancials)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                Group {
                    
                    switch companyOverview {
                    case .CompanyDetail:
                        CompanyDetailView(psxViewModel: psxViewModel)
                    case .CompanyFinancials:
                        CompanyFinancials(psxViewModel: psxViewModel)
                        
                    }
                    
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
            await psxViewModel.getSymbolOverview(symbol: symbol)
        }
    }
}

// MARK: - Supporting Views

struct CompanyFinancials: View {
    
    var psxViewModel: PsxViewModel
    
    
    
    var body: some View {
        
        switch psxViewModel.symbolOverviewEnums {
        case .initial:
            ProgressView()
                .frame(height: 200)
        case .loading:
            ProgressView()
                .frame(height: 200)
        case .loaded(let overview):
            FinancialCharts(annualItem: overview.financials.annual, quaterleyItem: overview.financials.quarterly,dataRatio: overview.ratios)
            
            
        case .error(let errorMessage):
            ErrorView(message: errorMessage)
        }
    }
}



struct CompanyDetailView: View {
    var psxViewModel: PsxViewModel
    
    var body: some View {
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
}


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
                    .frame(width: 350,height: 400)
            case .loading:
                ProgressView()
                    .frame(width:350,height: 400)
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


struct FinancialCharts: View {
    
    var annualItem: [Annual]
    var quaterleyItem:[Annual]
    var dataRatio:[Ratio]
    
    @State var chartSelector: ChartSelector = .Annual
    
    
    
    var body: some View {
        VStack {
            
            ChartSectionHeader(title: "Revenue & Profit")
            
            ChartCard {
                VStack(spacing:12) {
                    
                    Picker("Picker", selection: $chartSelector) {
                        Text("Annual").tag(ChartSelector.Annual)
                        Text("Quaterly").tag(ChartSelector.Quaterly)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    
                    Group {
                        
                        switch chartSelector {
                        case .Annual:
                            BarChart(item: annualItem)
                        case .Quaterly:
                            BarChart(item: quaterleyItem)
                            
                        }
                        
                    }
                    
                }
            }

            ChartSectionHeader(title: "Earnings Per Share (EPS)")
            
            Group {
                
                ChartCard {
                    switch chartSelector {
                    case .Annual:
                        EPSChart(items: annualItem)
                    case .Quaterly:
                        EPSChart(items: quaterleyItem)
                        
                    }
                }
                
            }
            
            ChartSectionHeader(title: "Profit Margin")
            
            ChartCard {
                RatioChart(data: dataRatio)
            }
            
            ChartSectionHeader(title: "Year-over-year EPS growth")
            
            ChartCard {
                RatioLineChart(data: dataRatio)
            }
            
            ChartSectionHeader(title: "PEG Ratio Trend")
            
            ChartCard {
                EpsRatioChart(data: dataRatio)
            }
            
        }
    }
}

struct BarChart: View {
    
    var item:[Annual]
    
    
    @State var selectedYear: String?
    
    func selectedItem(from annual: [Annual]) -> Annual? {
        guard let selectedYear else { return nil }
        return annual.first { $0.period == selectedYear }
    }
    
    var body: some View {
        Chart {
            ForEach(item,id: \.period) { value in
                BarMark(x: .value("Year", value.period ?? "2026"), y: .value("Amount", value.sales ?? 0)
                )
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .position(by: .value("Type", "Sales"))
                .annotation {
                    Text(value.sales ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                BarMark(x: .value("Year", value.period ?? "2026"), y: .value("Amount", value.profitAfterTax ?? 0)
                )
                .foregroundStyle(.green)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .position(by: .value("Type", "Profit"))
                .annotation {
                    Text(value.profitAfterTax ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.1))
                        )
                }
            }
            
            
        }
        .chartYScale(domain: calculateYScaleDomain(for: item))
        .frame(height: 300)
        .chartYAxis {
            AxisMarks{ value in
                if let doubleValue = value.as(Double.self) {
                    AxisValueLabel {
                        Text(doubleValue.formatted(
                            .number.notation(.compactName)
                        ))
                    }
                }
                
            }
        }
        .chartLegend(position: .bottom , alignment:.leading ,content: {
            HStack(spacing:16){
                LegendItem(color: .blue, label: "Sales")
                LegendItem(color: .green, label: "Profit")
            }
        })
        .chartLegend(.visible)
        .padding(.horizontal, 16)
        .padding(.vertical,4)
    }
}

struct EPSChart: View {
    let items: [Annual]
    
    var body: some View {
        Chart {
            ForEach(items, id: \.period) { value in
                LineMark(
                    x: .value("Year", value.period ?? ""),
                    y: .value("EPS", value.eps ?? 0)
                )
                .foregroundStyle(.pink)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Year", value.period ?? ""),
                    y: .value("EPS", value.eps ?? 0)
                )
                .foregroundStyle(.pink)
                .annotation {
                    Text(value.eps ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.pink)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.pink.opacity(0.1))
                        )
                }
            }
        }
        .frame(height: 300)
    }
}


struct ChartCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            )
    }
}


struct ChartSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 12)
    }
}


struct RatioChart: View {
    let data: [Ratio]
    
    var body: some View {
        Chart {
            // 1.  Margins – left axis
            ForEach(data, id: \.period) { d in
                BarMark(
                    x: .value("Year", d.period ?? ""),
                    y: .value("Margin", d.grossProfitMargin ?? 0.0)
                )
                .foregroundStyle(.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .position(by: .value("Type", "GrossProfit"))
                .annotation {
                    Text(d.grossProfitMargin ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.indigo)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.indigo.opacity(0.1))
                        )
                }
                
                BarMark(
                    x: .value("Year", d.period ?? ""),
                    y: .value("Margin", d.netProfitMargin ?? 0.0)
                )
                .foregroundStyle(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .position(by: .value("Type", "NetProfit"))
                .annotation {
                    Text(d.netProfitMargin ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )
                }
            }
        }
        .chartLegend(position: .bottom)
        .frame(height: 300)
        .padding()
    }
}


struct RatioLineChart: View {
    
    let data: [Ratio]
    
    var body: some View {
        Chart {
            
            ForEach(data, id: \.period) { d in
                LineMark(
                    x: .value("Year", d.period ?? ""),
                    y: .value("Growth", d.epsGrowth ?? 0.0)
                )
                .foregroundStyle(.gray)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Year", d.period ?? ""),
                    y: .value("Growth", d.epsGrowth ?? 0.0))
                .foregroundStyle(.gray)
                .annotation {
                    Text(d.epsGrowth ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                

            }
        }
        
        .chartLegend(position: .bottom)
        .frame(height: 300)
        .padding()
    }
}

struct EpsRatioChart: View {
    
    let data: [Ratio]
    
    var body: some View {
        Chart {
            
            ForEach(data, id: \.period) { d in
                LineMark(
                    x: .value("Year", d.period ?? ""),
                    y: .value("Growth", d.peg ?? 0.0)
                )
                .foregroundStyle(.mint)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Year", d.period ?? ""),
                    y: .value("Growth", d.peg ?? 0.0))
                .foregroundStyle(.mint)
                .annotation {
                    Text(d.peg ?? 0,format:.number.notation(.compactName))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.mint)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.mint.opacity(0.1))
                        )
                }
            }
        }
        
        .chartLegend(position: .bottom)
        .frame(height: 300)
        .padding()
    }
}





struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 4)
                .cornerRadius(2)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}



#Preview {
    TickerDetailView(symbol: "DCR")
}
