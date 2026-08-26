//
//  CompareStockView.swift
//  psx_sockets
//
//  Created by sarim khan on 24/07/2026.
//

import SwiftUI

struct CompareStockView: View {
    
    @State private var compareViewModel:CompareStockViewModel = CompareStockViewModel(psxServiceManager: PsxServiceManager())
    
    
    var body: some View {
        VStack{
            filterChips
            Divider()
            compareView
            
        }
        .sheet(isPresented: $compareViewModel.openBottomSheet) {
            NavigationStack{
                VStack{
                    switch compareViewModel.searchSymbolEnum {
                    case .Loading , .Initial:
                        ProgressView()
                    case .Loaded(let symbols):
                        List(symbols, id: \.self) { result in
                            HStack(spacing : 18){
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    
                                    Text(result.prefix(3))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                Text(result)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: compareViewModel.selectedSymbols.contains(result) ? "checkmark.seal" : "plus.circle.fill")
                                    .font(.body)
                                    .foregroundColor(compareViewModel.selectedSymbols.contains(result) ? .blue : .black.opacity(0))
                                
                            }
                            .onTapGesture {
                                compareViewModel.selectedSymbols.append(result)
                            }
                            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            
                        }
                        .listStyle(.plain)
                    case .Error(let error):
                        Text(error)
                    }
                }
                .searchable(text: $compareViewModel.filterSymbolString,placement: .navigationBarDrawer(displayMode: .always),prompt: "Search symbol")
                
                .onChange(of: compareViewModel.filterSymbolString) { oldValue, newValue in
                    compareViewModel.getAllFilterSymbols()
                }
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button(role:.cancel) {
                            Task{
                                await compareViewModel.getAllSymbolDetail()
                            }
                            compareViewModel.openBottomSheet.toggle()
                        }
                    }
                }
                
            }
            
            
        }
        
        
        .task {
            await compareViewModel.getAllSymbols()
        }
        
        .navigationTitle("Compare Stocks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    compareViewModel.openBottomSheet.toggle()
                } label: {
                    Image(systemName: "square.split.diagonal.fill")
                }
                
            }
        }
        .background(Color(.systemGroupedBackground))
        
    }
    
    @ViewBuilder
    private var filterChips: some View {
        if !compareViewModel.selectedSymbols.isEmpty{
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(compareViewModel.selectedSymbols, id: \.self) { symbol in
                        HStack(spacing: 8) {
                            Text(symbol)
                                .font(.subheadline.bold())
                            
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                        }
                        .onTapGesture {
                            compareViewModel.removeSymbol(symbol: symbol)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.12))
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 50)
        }else{
            ContentUnavailableView(
                "No Stocks Selected",
                systemImage: "chart.xyaxis.line",
                description: Text("Tap the + button to add stocks for comparison.")
            )
        }
    }
    

    
    @ViewBuilder
    private var compareView: some View {
        switch compareViewModel.compareStockEnum {
        case .Initial:
            Spacer()
        case .Loading:
            ProgressView("Loading comparison…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .Loaded(let symbols,let overview):
            if symbols.isEmpty {
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        stockCards(symbols)
                        comparisonTable(symbols,overview)
                    }
                    .padding()
                }
            }
        case .Error(let error):
            ContentUnavailableView("Couldn't load comparison", systemImage: "wifi.slash", description: Text(error))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func stockCards(_ symbols: [SymbolDetail]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(symbols, id: \.data.symbol) { detail in
                    stockCard(detail.data)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func stockCard(_ stock: SymbolDataClass) -> some View {
        let isUp = stock.change >= 0
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(stock.symbol)
                .font(.headline)
            
            Text(stock.price, format: .number.precision(.fractionLength(2)))
                .font(.title2.bold())
                .monospacedDigit()
            
            HStack(spacing: 4) {
                Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                Text("\(stock.change, specifier: "%.2f") (\(stock.changePercent, specifier: "%.2f")%)")
                    .monospacedDigit()
            }
            .font(.caption.bold())
            .foregroundColor(isUp ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill((isUp ? Color.green : Color.red).opacity(0.12))
            )
        }
        .padding(14)
        .frame(width: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.tertiarySystemBackground))
        )
    }
    
    private func comparisonTable(_ symbols: [SymbolDetail],_ symbolOverview:[SymbolOverview]) -> some View {
        
        let stocks = symbols.map(\.data)
        let financials = symbolOverview.map(\.financials)
        let ratios = symbolOverview.map { $0.ratios.first }

                
        
        let rows: [(String, (SymbolDataClass) -> String)] = [
            ("Volume", { $0.volume.formatted(.number.notation(.compactName)) }),
            ("Day Range", { $0.day_range }),
            ("52W Range", { $0.week_range_52 }),
            ("LDCP", { String(format: "%.2f", $0.ldcp) }),
            ("P/E", { String(format: "%.2f", $0.price_earning) }),
            ("YTD Change", { String(format: "%.2f%%", $0.ytd_change) }),
            ("Market Cap", { $0.market_cap.map { $0.formatted(.number.notation(.compactName)) } ?? "—" })
        ]
        
        let financialsRow : [ (String,(Financials)-> String) ] = [
            ("Sales",{ $0.annual.first?.sales.map {
                $0.formatted(.number.notation(.compactName))
            } ?? "_" } ),
            ("Profit After Tax", { $0.annual.first?.profitAfterTax.map { $0.formatted(.number.notation(.compactName)) } ?? "—" }),
            ("EPS", { $0.annual.first?.eps.map { String(format: "%.2f", $0) } ?? "—" }),
        ]
        
        let ratioRows: [(String, (Ratio) -> String)] = [
            ("Gross Margin", { $0.grossProfitMargin.map { String(format: "%.1f%%", $0) } ?? "—" }),
            ("Net Margin", { $0.netProfitMargin.map { String(format: "%.1f%%", $0) } ?? "—" }),
            ("EPS Growth", { $0.epsGrowth.map { String(format: "%.1f%%", $0) } ?? "—" }),
            ("PEG", { $0.peg.map { String(format: "%.2f", $0) } ?? "—" })
        ]
        
        return VStack(alignment: .leading, spacing: 0) {
            Text("Details")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                GridRow {
                    Text("")
                        .frame(width: 80, alignment: .leading)
                    ForEach(stocks, id: \.symbol) { stock in
                        Text(stock.symbol)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                }
                
                ForEach(rows, id: \.0) { label, valueFor in
                    Divider().gridCellUnsizedAxes(.horizontal)
                    GridRow {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .leading)
                        ForEach(stocks, id: \.symbol) { stock in
                            Text(valueFor(stock))
                                .font(.caption.bold())
                                .monospacedDigit()
                        }
                    }
                }
                
                ForEach(financialsRow, id: \.0) { label, valueFor in
                    Divider().gridCellUnsizedAxes(.horizontal)
                    GridRow {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        ForEach(financials, id: \.self) { financial in
                            Text(valueFor(financial))
                                .font(.caption.bold())
                                .monospacedDigit()
                        }
                    }
                }
                
                ForEach(ratioRows, id: \.0) { label, valueFor in
                    Divider().gridCellUnsizedAxes(.horizontal)
                    GridRow {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        ForEach(ratios, id: \.self) { ratio in
                            
                            Text(valueFor(ratio!))
                                .font(.caption.bold())
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

#Preview {
    CompareStockView()
}
