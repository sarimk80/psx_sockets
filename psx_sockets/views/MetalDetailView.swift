import SwiftUI
import Charts

struct MetalDetailView: View {

    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var selectedRange: PriceRange = .threeMonths
    @State private var selectedPoint: MetalModel?

    let metal: String

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch psxViewModel.metalEnums {

                case .initial, .loading:
                    loadingState

                case .loaded(let metalModel):
                    let parsed = parsedData(metalModel)
                    let filtered = filteredData(parsed)

                    priceHeader(filtered)
                    rangeSelector
                    chartCard(filtered)
                    listdata(parsed)
                    

                case .error(let message):
                    errorState(message)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(metal.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await psxViewModel.getAllMetal(metal: metal.lowercased())
        }
    }

    // MARK: - Data Helpers

    private func parsedData(_ raw: [MetalModel]) -> [(date: Date, price: Double, raw: MetalModel)] {
        raw.compactMap { item in
            guard let date = formatter.date(from: item.day),
                  let price = Double(item.maxPrice) else { return nil }
            return (date, price, item)
        }
        .sorted { $0.date < $1.date }
    }

    private func filteredData(_ data: [(date: Date, price: Double, raw: MetalModel)]) -> [(date: Date, price: Double, raw: MetalModel)] {
        guard let cutoff = selectedRange.cutoffDate else { return data }
        return data.filter { $0.date >= cutoff }
    }

    // MARK: - Price Header

    @ViewBuilder
    private func priceHeader(_ data: [(date: Date, price: Double, raw: MetalModel)]) -> some View {
        if let latest = data.last {
            let first = data.first?.price ?? latest.price
            let change = latest.price - first
            let percentChange = first != 0 ? (change / first) * 100 : 0
            let isPositive = change >= 0

            VStack(alignment: .leading, spacing: 6) {
                Text(currencyString(latest.price))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                HStack(spacing: 6) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption.weight(.bold))
                    Text("\(currencyString(abs(change))) (\(String(format: "%.2f", abs(percentChange)))%)")
                        .font(.subheadline.weight(.semibold))
                    Text(selectedRange.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(isPositive ? .green : .red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Range Selector

    private var rangeSelector: some View {
        HStack(spacing: 8) {
            ForEach(PriceRange.allCases) { range in
                Button {
                    withAnimation(.snappy) { selectedRange = range }
                } label: {
                    Text(range.label)
                        .font(.footnote.weight(.semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule().fill(selectedRange == range ? Color.accentColor : Color(.tertiarySystemFill))
                        )
                        .foregroundStyle(selectedRange == range ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Chart

    @ViewBuilder
    private func chartCard(_ data: [(date: Date, price: Double, raw: MetalModel)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let selected = selectedPoint,
               let match = data.first(where: { $0.raw.day == selected.day }) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(currencyString(match.price))
                        .font(.headline)
                }
                .transition(.opacity)
            }

            Chart {
                ForEach(data, id: \.raw.day) { item in
                    LineMark(
                        x: .value("Day", item.date),
                        y: .value("Price", item.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Day", item.date),
                        y: .value("Price", item.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }

                if let selected = selectedPoint,
                   let match = data.first(where: { $0.raw.day == selected.day }) {
                    RuleMark(x: .value("Day", match.date))
                        .foregroundStyle(.gray.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                    PointMark(
                        x: .value("Day", match.date),
                        y: .value("Price", match.price)
                    )
                    .foregroundStyle(Color.accentColor)
                    .symbolSize(80)
                }
            }
            .frame(height: 260)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) {
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateSelection(at: value.location, proxy: proxy, geo: geo, data: data)
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selectedPoint = nil
                                    }
                                }
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func updateSelection(at location: CGPoint, proxy: ChartProxy, geo: GeometryProxy, data: [(date: Date, price: Double, raw: MetalModel)]) {
        guard let plotFrame = proxy.plotFrame else { return }
        let origin = geo[plotFrame].origin
        let xPosition = location.x - origin.x
        guard let date: Date = proxy.value(atX: xPosition) else { return }

        if let closest = data.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
            selectedPoint = closest.raw
        }
    }

    private func currencyString(_ value: Double) -> String {
        "Rs. " + String(format: "%.2f", value)
    }
    
    
    @ViewBuilder
    private func listdata(_ data: [(date: Date, price: Double, raw: MetalModel)]) -> some View {
        ForEach(Array(data.reversed().enumerated()), id: \.element.date) { index, item in
            HStack {
                Text(item.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(currencyString(item.price))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                
            }
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading \(metal.capitalized) prices…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Couldn't load data")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await psxViewModel.getAllMetal(metal: metal.lowercased()) }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Range Enum

enum PriceRange: String, CaseIterable, Identifiable {
    case oneMonth, threeMonths, sixMonths, oneYear, all

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneMonth: return "1M"
        case .threeMonths: return "3M"
        case .sixMonths: return "6M"
        case .oneYear: return "1Y"
        case .all: return "All"
        }
    }

    var cutoffDate: Date? {
        let calendar = Calendar.current
        switch self {
        case .oneMonth: return calendar.date(byAdding: .month, value: -1, to: .now)
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: .now)
        case .sixMonths: return calendar.date(byAdding: .month, value: -6, to: .now)
        case .oneYear: return calendar.date(byAdding: .year, value: -1, to: .now)
        case .all: return nil
        }
    }
}

#Preview {
    NavigationStack {
        MetalDetailView(metal: "gold")
    }
}
