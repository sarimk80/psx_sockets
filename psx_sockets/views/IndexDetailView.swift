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
    
    @State private var scrollPosition: Date = .now
        
   
    
    var body: some View {
        ZStack {
            List {

                if psxViewModel.indexSymbols.isEmpty {

                    // MARK: - Chart Skeleton
                    Section {
                        ChartLoading()
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            .listRowSeparator(.hidden)
                    }

                    // MARK: - Rows Skeleton
                    Section {
                        ForEach(0..<5, id: \.self) { _ in
                            PortfolioStockRow(result: SymbolDataClass.mock)
                                .redacted(reason: .placeholder)
                                .listRowInsets(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                                .listRowSeparator(.hidden)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
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

                } else {

                    // MARK: - Real Chart
                    Section {
                        HStack(alignment: .top, spacing: 8){
                            BigCard()
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    showLineSheet.toggle()
                                }
                            VStack(spacing: 8){
                                SmallCard(title: "Allocation", subtitle: "Distribution", image: "chart.pie",color: .orange)
                                    .onTapGesture {
                                        showSectorSheet.toggle()
                                    }
                                SmallCard(title: "Index Stats", subtitle: "Market Snapshot", image: "chart.bar.horizontal.page",color: .pink)
                                    .onTapGesture {
                                        showIndexSheet.toggle()
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    .listRowBackground(Color(.secondarySystemBackground))
                    .listRowSeparator(.hidden)

                    // MARK: - Real Rows
                    Section {
                        ForEach(psxViewModel.indexSymbols, id: \.data.symbol) { result in
                            PortfolioStockRow(result: result.data)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    appNavigation.tickerNavigation.append(
                                        TickerDetailRoute.tickerDetail(symbol: result.data.symbol)
                                    )
                                }
                        }
                    } header: {
                        HStack {
                            Text("Stocks")
                                .font(.headline)
                                .textCase(nil)

                            Spacer()

                            Text("\(psxViewModel.indexSymbols.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
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
            await psxViewModel.getIndexSymbolAllDetail(indexEnum: indexName)
        }
        .sheet(isPresented: $showSectorSheet) {
            chartView
                .presentationDetents([indexName == .kse_100 ? .large : .medium])
                .presentationBackground(Color(.systemBackground))
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showIndexSheet) {
            statsView
                .presentationDetents([.height(260)])
                .presentationBackground(Color(.systemBackground))
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLineSheet) {
            lineView
                .presentationDetents([.medium])
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
                HStack{
                    Button {
                        showSectorSheet.toggle()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .fontWeight(.medium)
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glass)
                    
                    Spacer()

                    
                }
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
    private var statsView: some View{
        VStack(alignment:.leading){
            
            Button {
                showIndexSheet.toggle()
            } label: {
                Image(systemName: "xmark.circle")
                    .fontWeight(.medium)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.glass)
            .padding(.horizontal,8)
            .padding(.top,8)
            
            Spacer()
            
            TickerView(tickerDetail: tickerDetail)
                .frame(height: 200)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 8)
            
        }
        
    }
    
    @ViewBuilder
    private var lineView: some View {
        switch psxViewModel.kLineEnum {
        case .initial:
            ProgressView()
        case .loading:
            ProgressView()
        case .loaded(let data):
            KlineChartView(kline: data, scrollPosition: $scrollPosition)
                .padding()
        case .error(let errorMessage):
            Text(errorMessage)
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
        .background(Color(.systemBackground))
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
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

