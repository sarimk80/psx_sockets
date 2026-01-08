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
            if webSocketManager.portfolioUpdate.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading portfolio data...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                List {
                    // Chart Section
                    Section {
                        chartView
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    
                    
                    // Stocks Section
                    Section {
                        ForEach(webSocketManager.portfolioUpdate, id: \.symbol) { result in
                            PortfolioStockRow(result: result)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    appNavigation.tickerNavigation.append(
                                        TickerDetailRoute.tickerDetail(symbol: result.symbol)
                                    )
                                }
                        }
                    } header:{
                        HStack {
                            Text("Stocks")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                            Spacer()
                            Text("\(webSocketManager.portfolioUpdate.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                    )
                }
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .navigationTitle(IndexEnumToString(indexEnum: indexName))
                .navigationBarTitleDisplayMode(.large)
            }
        }
        
        .task {
            await psxViewModel.getIndexData(indexEnum: indexName)
            await webSocketManager.getIndexDetail(index: indexName)
        }
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch psxViewModel.indexDetailEnum {
        case .initial, .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading chart...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            
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
                .frame(height: 350)
                .chartLegend(position: .bottom, alignment: .leading, spacing: 12)
                
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
