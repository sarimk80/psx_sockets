//
//  IndexDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 07/01/2026.
//
import SwiftUI
import Charts

struct IndexDetailView: View {
    
    var indexName: IndexEnums
    var tickerDetail: SymbolDataClass
    
    @Environment(WebSocketManager.self) private var webSocketManager
    @Binding var appNavigation: AppNavigation
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var showSectorSheet:Bool = false
    @State private var showIndexSheet:Bool = false
    @State private var showLineSheet:Bool = false
    @State private var showFilterSheet:Bool = false
    
    @State private var scrollPosition: Date = .now
    
    @State private var indexFilter:IndexFilterEnums = .Current
    
    
    
    var body: some View {
        ZStack {
            List {
                
                switch psxViewModel.indexTickerEnums {
                case .initial, .loading:
                    indexDetailLoading
                case .loaded(let indexTicker):
                    IndexDetailLoaded(indexTicker: indexTicker,
                                      onChartClick: {self.showLineSheet.toggle()},
                                      onSectorClick: {self.showSectorSheet.toggle()},
                                      onIndexClick: {self.showIndexSheet.toggle()} ,
                                      onFilterClick: {self.showFilterSheet.toggle()},
                                      appNavigation: appNavigation,
                                      indexFilter: $indexFilter)
                case .error(let message):
                    Text(message)
                }
                
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle(IndexEnumToString(indexEnum: indexName))
        .navigationBarTitleDisplayMode(.large)
        .task {
            if case IndexDetailEnums.initial  = psxViewModel.indexDetailEnum{
                await psxViewModel.getIndexData(indexEnum: indexName)
            }
            await psxViewModel.getKlineSymbol(symbol: IndexEnumToString(indexEnum: indexName), timeFrame: "1d")
            await psxViewModel.getAllIndexTicker(index: IndexEnumToString(indexEnum: indexName))
        }
        .onChange(of: indexFilter, { oldValue, newValue in
            Task{
                await psxViewModel.filterIndexTicker(filterEnums: newValue)
            }
        })
        .sheet(isPresented: $showSectorSheet) {
            SheetContainer(title: "Sector Breakdown", content: {
                chartView
            }, onClose: {
                showSectorSheet = false
            })
            .presentationDetents([indexName == .kse_100 ? .large : .medium])
            .presentationBackground(Color(.systemBackground))
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showIndexSheet) {
            SheetContainer(title: "Index Overview", content: {
                statsView
            }, onClose: {
                showIndexSheet = false
            })
            .presentationDetents([.medium])
            .presentationBackground(Color(.systemBackground))
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLineSheet) {
            SheetContainer(title: "Performance Trend", content: {
                lineView
            }, onClose: {
                showLineSheet = false
            })
            
        }
        .sheet(isPresented: $showFilterSheet) {
            Form{
                
                Section {
                    HStack{
                        Text("Filters")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture {
                                self.showFilterSheet.toggle()
                            }
                    }
                }
                .listRowBackground(Color(.clear))
                
                Section {
                    Picker("Picker", selection: $indexFilter) {
                        ForEach(IndexFilterEnums.allCases) { temp in
                            Text(temp.rawValue)
                                .tag(temp)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Filter by: ")
                }
                .listRowBackground(Color(.clear))
                
                Section {
                    Button {
                        showFilterSheet.toggle()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .padding(.vertical,6)
                    }
                    .buttonSizing(.flexible)
                    .buttonStyle(.glassProminent)
                }
                .listRowBackground(Color.clear)

            }
                            
            .presentationDetents([.fraction(0.8)])
            .presentationBackground(Color(.systemBackground))
            .presentationDragIndicator(.visible)

        }
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch psxViewModel.indexDetailEnum {
        case .initial, .loading:
            ChartLoading()
            
        case .loaded(_, let groupData):
            VStack(alignment: .center, spacing: 16) {
                
                Chart(groupData, id: \.sectorName) { result in
                    SectorMark(
                        angle: .value("Count", result.sectorStockCount),
                        innerRadius: .ratio(0.65),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Sector", result.sectorName))
                    .cornerRadius(4)
                }
                .frame(height:indexName == .kse_100 ? 700 : 350)
                .chartLegend(position: .bottom, alignment: .leading, spacing: 12)
                
            }
            .padding(8)
            
        case .error(let errorMessage):
            VStack(spacing: 12) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Unable to Load Chart")
                    .font(.headline)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            
        }
    }
    
    @ViewBuilder
    private var statsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header: symbol name & price/change
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tickerDetail.symbol)
                            .font(.title2.bold())
                        if let fullName = tickerDetail.fullName, !fullName.isEmpty {
                            Text(fullName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(tickerDetail.price, format: .number.precision(.fractionLength(2)))
                            .font(.title2.monospacedDigit())
                        HStack(spacing: 4) {
                            Image(systemName: tickerDetail.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption2)
                            Text(tickerDetail.change, format: .number.sign(strategy: .automatic).precision(.fractionLength(2)))
                            Text("(\(tickerDetail.changePercent, format: .number.precision(.fractionLength(2)))%)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                        .foregroundColor(tickerDetail.change >= 0 ? .green : .red)
                    }
                }
                
                Divider()
                
                // Grid of key metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricCell(title: "High", value: tickerDetail.high, format: .number.precision(.fractionLength(2)))
                    MetricCell(title: "Low", value: tickerDetail.low, format: .number.precision(.fractionLength(2)))
                    MetricCell(title: "Volume", value: tickerDetail.volume, format: .number.notation(.compactName))
                   
                   
                    MetricCell(title: "1Y Change", value: tickerDetail.year_1_change, format: .number.precision(.fractionLength(2)), isPercent: true)
                    MetricCell(title: "YTD Change", value: tickerDetail.ytd_change, format: .number.precision(.fractionLength(2)), isPercent: true)
                    MetricCell(title: "Day Range", value: tickerDetail.day_range, isString: true)
                    MetricCell(title: "52W Range", value: tickerDetail.week_range_52, isString: true)
                    
                    MetricCell(title: "LDCP", value: tickerDetail.ldcp, format: .number.precision(.fractionLength(2)))
                    
                }
            }
            .padding(12)
            //.background(Color(.secondarySystemBackground))
            //.clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 8)
        }
        //.frame(maxHeight: 200) // respects sheet detent
    }

    // Helper view for a single metric
    private struct MetricCell: View {
        let title: String
        let value: String
        
        init(title: String, value: String) {
            self.title = title
            self.value = value
        }
        
        // Convenience initializers for numeric/percent/string values
        init(title: String, value: some Numeric, format: FloatingPointFormatStyle<Double>, isPercent: Bool = false) {
            self.title = title
            let formatted = (value as? Double ?? Double("\(value)") ?? 0)
            self.value = isPercent ? formatted.formatted(format) + "%" : formatted.formatted(format)
        }
        
        init(title: String, value: String, isString: Bool) {
            self.title = title
            self.value = value
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var lineView: some View {
        switch psxViewModel.kLineEnum {
        case .initial:
            ProgressView()
        case .loading:
            ProgressView()
        case .loaded(_,let kLineData):
            KlineChartView(kline: kLineData, scrollPosition: $scrollPosition,showVolume: false)
        case .error(let errorMessage):
            Text(errorMessage)
        }
    }
    
    @ViewBuilder
    private var indexDetailLoading: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                
                BigCardSkeleton()
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 16) {
                    SmallCardSkeleton()
                    SmallCardSkeleton()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        
        Section {
            ForEach(0..<5, id: \.self) { _ in
                PortfolioStockRow(result: SymbolDataClass.mock)
                    .redacted(reason: .placeholder)
                    .listRowInsets(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.tertiarySystemBackground))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    )
            }
        } header: {
                Text("Stocks")
                    .redacted(reason: .placeholder)
                    .font(.headline)
                    .textCase(nil)
                
                
            
            
        }
    }
    
    
    
}

struct IndexDetailLoaded: View {
    
    let indexTicker:[IndexTickers]
    let onChartClick: () -> Void
    let onSectorClick: () -> Void
    let onIndexClick: () -> Void
    let onFilterClick:() -> Void
    
    var appNavigation: AppNavigation
    
    @Binding var indexFilter: IndexFilterEnums
    
    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 8){
                BigCard()
                    .frame(maxWidth: .infinity)
                
                    .onTapGesture {
                        onChartClick()
                    }
                VStack(spacing: 8){
                    SmallCard(title: "Allocation", subtitle: "Distribution", image: "chart.pie",color: .orange)
                        .onTapGesture {
                            onSectorClick()
                        }
                    SmallCard(title: "Index Stats", subtitle: "Market Snapshot", image: "chart.bar.horizontal.page",color: .pink)
                        .onTapGesture {
                            onIndexClick()
                        }
                }
                .frame(maxWidth: .infinity)
            }
            
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        
        // MARK: - Real Rows
        Section {
            ForEach(indexTicker, id: \.symbol) { result in
                IndexList(indexDetail: result,indexFilter: $indexFilter)
                    .onTapGesture {
                        appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: result.symbol))
                    }
            }
        } header: {
            HStack(spacing: 4) {
                Text("Stocks")
                    .font(.headline)
                    .textCase(nil)
                
                Spacer()
                
                HStack(spacing: 2){
                    Image(systemName: "line.3.horizontal.decrease")
                    Text("Filter")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.accent)
                .onTapGesture {
                    onFilterClick()
                }
                
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 12, trailing: 8))
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        )
        
    }
}

struct IndexList:View {
    let indexDetail: IndexTickers
    
    @Binding var indexFilter:IndexFilterEnums
    
    
    private var trendColor: Color {
        indexDetail.change > 0 ? .green : .red
    }
    
    var body: some View{
        
        HStack(spacing: 16) {
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
                
                Text(indexDetail.symbol.prefix(3))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(trendColor)
            }
            
            VStack(alignment: .leading,spacing:6){
                Text(indexDetail.symbol)
                    .font(.system(.headline, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(indexDetail.name)
                    .font(.system(.caption2, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment:.trailing){
                
                indexValue
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                
                    
                
                HStack(spacing: 6) {
                    // Percentage change pill
                    Text("\(indexDetail.change > 0 ? "+" : "")\(indexDetail.change, specifier: "%.2f")")
                        .font(.system(.caption2, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(trendColor.opacity(0.12))
                        )
                    
                    
                    Text(indexDetail.volume)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
        .padding(.horizontal,6)
        
    }
    
    @ViewBuilder
    var indexValue: some View {
        switch indexFilter {
        case .Current:
            Text("\(indexDetail.current)")

        case .High:
            Text("High: \(indexDetail.current)")

        case .IndexWeight:
            Text("Index Weight: \(indexDetail.idxWeight.formatted(.number))")

        case .Low:
            Text("Low: \(indexDetail.current)")

        case .MarketCap:
            Text("Market Cap: \(indexDetail.marketCap.formatted(.number))")

        case .Volume:
            Text("Vol: \(indexDetail.volume)")
        }
    }
}

struct BigCard: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "chart.bar")
                .font(.system(size: 35))
                .foregroundColor(.mint)
                .padding(.bottom,12)
            
            Text("Index Activity")
                .font(.headline)
            
            Text("Current Trend")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct SmallCard: View {
    let title: String
    let subtitle: String
    let image: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: image)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}



struct SheetContainer<Content: View>: View {
    let title: String
    let content: Content
    let onClose: () -> Void
    
    init(title: String,
         @ViewBuilder content: () -> Content,
         onClose: @escaping () -> Void) {
        self.title = title
        self.content = content()
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            Divider()
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
}


struct BigCardSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 140, height: 16)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 110, height: 14)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct SmallCardSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 16)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 16)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
