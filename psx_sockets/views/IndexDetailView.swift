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
    
    @Environment(WebSocketManager.self) private var webSocketManager
    @Binding var appNavigation: AppNavigation
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
   
    
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
                        chartView
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))

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
            await psxViewModel.getIndexSymbolAllDetail(indexEnum: indexName)
        }
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch psxViewModel.indexDetailEnum {
        case .initial, .loading:
            ChartLoading()
            
        case .loaded(_, let groupData):
            VStack(alignment: .leading, spacing: 16) {
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
                //.chartLegend(indexName == .kse_100 ? .hidden : .visible)
                
            }
            .padding(.vertical, 8)
            
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
}
