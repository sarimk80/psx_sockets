import SwiftUI
import Charts

struct MetalDetailView: View {
    
    @State private var viewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    @State private var chartSelection: ChartRange = .all
    @State private var unitEnum: UnitEnum = .Ounce
    @State private var karatEnum: KaratEnum = .k_24
    
    @State private var showSheet: Bool = false
    
    let metal: String
    let color: Color
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch viewModel.metalEnums {
                case .initial, .loading:
                    VStack(alignment: .leading, spacing: 16) {
                        // Summary header
                        summaryHeader(for: [MetalModel.mock])
                            .redacted(reason: .placeholder)
                        
                        // Chart
                        LineChartLoading()
                            
                        
                        // Historical data list
                        historicalListView(for: [MetalModel.mock])
                            .redacted(reason: .placeholder)
                    }
                    .padding(.horizontal,8)
                    
                case .loaded(let metals):
                    if metals.isEmpty {
                        emptyStateView
                    } else {
                        // Main content
                        VStack(alignment: .leading, spacing: 16) {
                            // Summary header
                            summaryHeader(for: metals)
                                .padding(.horizontal,8)
                            
                            Picker("", selection: $chartSelection, content: {
                                ForEach(ChartRange.allCases,id: \.self) { period in
                                    Text(period.rawValue)
                                        .tag(period)
                                }
                            })
                            .pickerStyle(.segmented)
                            .padding(.horizontal,8)
                            .onChange(of: chartSelection) { old, new in
                                viewModel.filterChartPeriod(chartRange: new,metal: metals)
                            }
                            
                            // Chart
                            chartView(for: viewModel.filterMetals)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                )
                                .frame(height: 350)
                            
                            // Historical data list
                            historicalListView(for: metals)
                                .padding(.horizontal,8)
                        }
                        
                    }
                    
                case .error(let message):
                    errorView(message: message)
                }
            }
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(SymbolToString(symbol: metal))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            if(metal == "GC=F" || metal == "SI=F"){
                ToolbarItem {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .onTapGesture {
                            showSheet.toggle()
                        }
                }
            }
            
        })
        .task {
            await viewModel.getAllMetal(metal: metal)
        }
        .sheet(isPresented: $showSheet) {
            List{
                
                Section {
                    HStack{
                        Text("Unit Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button {
                            showSheet.toggle()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .glassEffect()
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                
                Section {
                    HStack(alignment: .center){
                        Spacer()
                        Text(viewModel.metalConverstion,format: .number.precision(.fractionLength(2)))
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                } footer: {
                    HStack{
                        Text(unitEnum.rawValue)
                        Spacer()
                        Text(karatEnum.rawValue)
                    }
                    .font(.caption)
                    .fontWeight(.light)
                    
                }


                Section(header: Text("Weight Unit")) {
                    Picker("Choose Weight Unit", selection: $unitEnum) {
                        ForEach(UnitEnum.allCases,id: \.self) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    }
                .headerProminence(.standard)
                
                
                Section(header: Text("Purity")) {
                    Picker("Choose Purity", selection: $karatEnum) {
                        ForEach(KaratEnum.allCases,id: \.self) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    }
                    .headerProminence(.standard)

                
            }
            .presentationDetents([.fraction(0.6)])
            .onChange(of: unitEnum) { old, new in
                viewModel.changeMetalPrice(unitEnum: new, karatEnum: karatEnum)
            }
            .onChange(of: karatEnum) { old, new in
                viewModel.changeMetalPrice(unitEnum: unitEnum, karatEnum: new)
            }

        }
    }
}

extension MetalDetailView {
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading \(SymbolToString(symbol: metal)) data…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No data available for \(SymbolToString(symbol: metal))")
                .font(.headline)
            Text("Try selecting a different period or check back later.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.getAllMetal(metal: metal) }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
    
    @ViewBuilder
    private func summaryHeader(for metals: [MetalModel]) -> some View {
        
        if let latest = metals.last {
            let previous = metals.count > 1 ? metals[metals.count - 2] : nil
            let change = previous.map { latest.high - $0.high }
            let changePercent = previous.map {
                $0.high > 0 ? (change! / $0.high) * 100 : 0
            }
            

            HStack(alignment: .center, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(latest.high, format: .number.precision(.fractionLength(2)) )
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let change, let percent = changePercent {
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0
                                      ? "arrow.up.right"
                                      : "arrow.down.right")

                                Text(
                                    change,
                                    format: .number.precision(.fractionLength(2))
                                )

                                Text(" (\(String(format: "%.2f", percent))%)")
                            }
                            .font(.caption)
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                    }
                }

                

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Range")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("L: \(latest.low, format: .number.precision(.fractionLength(2)) )")
                        Text("C: \(latest.close, format: .number.precision(.fractionLength(2)) )")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    
    @ViewBuilder
    private func chartView(for metals: [MetalModel]) -> some View {
        let latest = metals.last
        
        Chart(metals, id: \.id) { item in
            LineMark(
                x: .value("Date", item.parsedDate ?? Date.now),
                y: .value("Price", item.high)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            .interpolationMethod(.cardinal)
            
            AreaMark(
                x: .value("Date", item.parsedDate ?? Date.now),
                y: .value("Price", item.high)
            )
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.05)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.cardinal)
            
            if let latest = latest, item.id == latest.id {
                RuleMark(
                    y: .value("Price", item.high)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(color.opacity(0.6))
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { value in
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal,8)
    }
    
    @ViewBuilder
    private func historicalListView(for metals: [MetalModel]) -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Historical Data")
                .font(.headline)
                .padding(.top, 4)
            
            ForEach(metals.reversed(), id: \.id) { item in
                HStack {
                    Text(item.parsedDate ?? Date.now,format: .dateTime)
                        .font(.subheadline)
                    
                    Spacer()
                    Text(item.high, format: .number.precision(.fractionLength(2)))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                
            }
        }
    }
}


#Preview {
    NavigationStack {
        MetalDetailView(metal: "gold",color: .pink)
    }
}
