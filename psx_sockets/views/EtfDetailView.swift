//
//  EtfDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 05/05/2026.
//

import SwiftUI

// MARK: - Main Detail View

struct EtfDetailView: View {
    @Environment(MoreNavigation.self) private var moreNavigation
    @State private var psxVM: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    let etf: Etf

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Hero Header
                EtfHeroCard(etf: etf)
                    .padding(.horizontal)
                    .padding(.top, 12)

                // Fund Stats
                EtfSectionHeader(title: "Fund Overview", icon: "chart.bar.fill")
                    .padding(.top, 28)

                FundStatsGrid(etf: etf)
                    .padding(.horizontal)
                
                EtfSectionHeader(title: "ETF Detail", icon: "chart.line.uptrend.xyaxis")
                    .padding(.top, 28)
                
                switch psxVM.symbolDetailEnum{
                case .initial, .loading:
                    FundPriceStatsGridSkeleton()
                case .loaded(portfolioTickers: let portfolioTickers):
                    FundPriceStatsGrid(pt: portfolioTickers)
                        .padding(.horizontal)
                case .error(let message):
                    Text(message)
                }

                // Key People
                if !etf.keyPeople.isEmpty {
                    EtfSectionHeader(title: "Key People", icon: "person.2.fill")
                        .padding(.top, 28)

                    VStack(spacing: 10) {
                        ForEach(etf.keyPeople, id: \.person) { person in
                            KeyPersonRow(person: person)
                        }
                    }
                    .padding(.horizontal)
                }

                // Holdings
                if !etf.symbols.isEmpty {
                    EtfSectionHeader(title: "Holdings", icon: "list.bullet.rectangle.fill")
                        .padding(.top, 28)

                    VStack(spacing: 10) {
                        ForEach(etf.symbols, id: \.ticker) { symbol in
                            HoldingRow(symbol: symbol)
                                .onTapGesture {
                                    moreNavigation.push(route: .tickerDetail(symbol: symbol.ticker))
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(etf.etfName)
        .navigationSubtitle(etf.fullName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await psxVM.getSymbolDetail(ticker: etf.etfName)
        }
    }
}

// MARK: - Hero Card

struct EtfHeroCard: View {
    let etf: Etf

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(etf.fullName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Label(etf.type, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue, in: Capsule())
                }
                Spacer()

                Image(systemName: "building.columns.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.blue.opacity(0.25))
            }

            Divider()

            Text(etf.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Fund Stats Grid

struct FundStatsGrid: View {
    let etf: Etf

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            EtfStatCard(label: "Fund Size", value: etf.fundSize, icon: "dollarsign.circle.fill", color: .green,numberValue: nil)
            EtfStatCard(label: "Market Cap", value: etf.marketCap, icon: "chart.line.uptrend.xyaxis", color: .blue,numberValue: nil)
            EtfStatCard(label: "No. of Shares", value: etf.noOfShares, icon: "square.stack.fill", color: .orange,numberValue: nil)
            EtfStatCard(label: "Fund Type", value: etf.type, icon: "tag.fill", color: .purple,numberValue: nil)
        }
    }
}


struct EtfStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    let numberValue:Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if numberValue != nil {
                Text(numberValue ?? 0.0,format: .number.precision(.fractionLength(2)))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }else{
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Section Header

struct EtfSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.blue)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

// MARK: - Key Person Row

struct KeyPersonRow: View {
    let person: EtfKeyPerson

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 42, height: 42)
                Text(String(person.person.prefix(1)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(person.person)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(person.position.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Holding Row

struct HoldingRow: View {
    let symbol: Symbol

    var weightPercent: String {
        String(format: "%.2f%%", symbol.weight * 100)
    }

    var weightColor: Color {
        switch symbol.weight {
        case 0.1...: return .green
        case 0.05..<0.1: return .orange
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Ticker Badge
            Text(symbol.ticker)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 8))
                .fixedSize()

            VStack(alignment: .leading, spacing: 2) {
                Text(symbol.company)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("Weight")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(symbol.weight,format: .number.precision(.fractionLength(2)))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.blue)

                // Mini weight bar
                GeometryReader { geo in
                    Capsule()
                        .fill(Color.blue.opacity(0.2))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: geo.size.width * min(symbol.weight, 1.0))
                        }
                }
                .frame(width: 60, height: 4)
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}


// MARK: - Fund Price Stats Grid

struct FundPriceStatsGrid: View {
    let pt: SymbolDetail

    private var data: SymbolDataClass { pt.data }

    var body: some View {
        VStack(spacing: 16) {
            // Primary price hero
            PriceHeroCard(data: data)

            // OHLC + Change row
            HStack(spacing: 10) {
                MiniStatCard(label: "High", value: data.high, trend: .up)
                MiniStatCard(label: "Low", value: data.low, trend: .down)
                MiniStatCard(label: "LDCP", value: data.ldcp, trend: .neutral)
            }

            // Range bars
            RangeCard(
                title: "Day Range",
                range: data.day_range,
                current: data.price,
                low: data.low,
                high: data.high
            )

            RangeCard(
                title: "52-Week Range",
                range: data.week_range_52,
                current: data.price,
                low: parseRangeLow(data.week_range_52),
                high: parseRangeHigh(data.week_range_52)
            )

            // Secondary stats
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                DetailStatCell(label: "Volume", value: data.volume.formatted(), icon: "waveform.bar.chart", color: .mint)
               
               
                DetailStatCell(label: "Circuit Breaker", value: data.circuit_breaker, icon: "bolt.shield", color: .red)
            }


            // Bid / Ask
            BidAskCard(
                bid: data.bid, bidVol: data.bidVol,
                ask: data.ask, askVol: data.askVol
            )
        }
    }

    // MARK: Helpers
    private func parseRangeLow(_ range: String) -> Double {
        Double(range.components(separatedBy: "—").first?.trimmingCharacters(in: .whitespaces) ?? "") ?? data.low
    }
    private func parseRangeHigh(_ range: String) -> Double {
        Double(range.components(separatedBy: "—").last?.trimmingCharacters(in: .whitespaces) ?? "") ?? data.high
    }
}

// MARK: - Price Hero Card

struct PriceHeroCard: View {
    let data: SymbolDataClass

    private var isPositive: Bool { data.change >= 0 }
    private var changeColor: Color { isPositive ? .green : .red }
    private var changeIcon: String { isPositive ? "arrow.up.right" : "arrow.down.right" }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.symbol)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text(data.price,format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                if let name = data.fullName {
                    Text(name)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: changeIcon)
                        .font(.caption2)
                    Text(data.change,format: .number.precision(.fractionLength(2)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(changeColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(changeColor.opacity(0.12), in: Capsule())

                Text("\(data.changePercent, specifier: "%.2f")%")
                    .font(.caption)
                    .foregroundStyle(changeColor)

                if let sector = data.sectorName {
                    Text(sector)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.8), in: Capsule())
                }
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Mini Stat Card (High / Low / LDCP)

enum Trend { case up, down, neutral }

struct MiniStatCard: View {
    let label: String
    let value: Double
    let trend: Trend

    private var color: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .neutral: return .secondary
        }
    }
    private var icon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "minus"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(color)

            Text(value,format: .number.precision(.fractionLength(2)))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Range Card

struct RangeCard: View {
    let title: String
    let range: String
    let current: Double
    let low: Double
    let high: Double

    private var progress: Double {
        guard high > low else { return 0 }
        return min(max((current - low) / (high - low), 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(range)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemFill))
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)

                    // Current price thumb
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                        .frame(width: 12, height: 12)
                        .offset(x: max(0, geo.size.width * progress - 6))
                }
            }
            .frame(height: 12)

            HStack {
                Text(low,format: .number.notation(.compactName))
                Spacer()
                Text(current,format: .number.precision(.fractionLength(2)))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
                Text(high,format:.number.notation(.compactName))
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Detail Stat Cell

struct DetailStatCell: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Return Badge

struct ReturnBadge: View {
    let label: String
    let value: Double

    private var isPositive: Bool { value >= 0 }
    private var color: Color { value == 0 ? .secondary : (isPositive ? .green : .red) }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                if value != 0 {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 8, weight: .bold))
                }
                Text(value == 0 ? "N/A" : "\(abs(value), specifier: "%.2f")%")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Bid Ask Card

struct BidAskCard: View {
    let bid: Double
    let bidVol: Int
    let ask: Double
    let askVol: Int

    private var spread: Double { ask - bid }

    var body: some View {
        HStack(spacing: 0) {
            // Bid side
            VStack(spacing: 6) {
                Text("BID")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                Text(bid,format: .number.precision(.fractionLength(2)))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                    .monospacedDigit()
                Text("Vol: \(bidVol.formatted())")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green.opacity(0.07))

            // Spread divider
            VStack(spacing: 2) {
                Text("SPREAD")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.tertiary)
                Text(spread,format: .number.precision(.fractionLength(2)))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 8)

            // Ask side
            VStack(spacing: 6) {
                Text("ASK")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                Text(ask,format: .number.precision(.fractionLength(2)))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .monospacedDigit()
                Text("Vol: \(askVol.formatted())")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.07))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}



struct FundPriceStatsGridSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            
            PriceHeroCardSkeleton()
            
            HStack(spacing: 10) {
                MiniStatCardSkeleton()
                MiniStatCardSkeleton()
                MiniStatCardSkeleton()
            }
            
            RangeCardSkeleton()
            RangeCardSkeleton()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                DetailStatCellSkeleton()
                DetailStatCellSkeleton()
            }
            
            BidAskCardSkeleton()
        }
        .padding(.horizontal)
    }
}

struct PriceHeroCardSkeleton: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 60, height: 12)
                SkeletonView(width: 120, height: 34)
                SkeletonView(width: 160, height: 10)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 10) {
                SkeletonView(width: 70, height: 24)
                    .clipShape(Capsule())
                SkeletonView(width: 50, height: 10)
                SkeletonView(width: 80, height: 16)
                    .clipShape(Capsule())
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct MiniStatCardSkeleton: View {
    var body: some View {
        VStack(spacing: 8) {
            SkeletonView(width: 40, height: 10)
            SkeletonView(width: 60, height: 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct RangeCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                SkeletonView(width: 90, height: 10)
                Spacer()
                SkeletonView(width: 80, height: 10)
            }
            
            SkeletonView(width: .infinity, height: 6)
                .clipShape(Capsule())
            
            HStack {
                SkeletonView(width: 40, height: 10)
                Spacer()
                SkeletonView(width: 60, height: 12)
                Spacer()
                SkeletonView(width: 40, height: 10)
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct DetailStatCellSkeleton: View {
    var body: some View {
        HStack(spacing: 10) {
            SkeletonView(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            
            VStack(alignment: .leading, spacing: 6) {
                SkeletonView(width: 60, height: 8)
                SkeletonView(width: 80, height: 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
    }
}


struct BidAskCardSkeleton: View {
    var body: some View {
        HStack {
            
            VStack(spacing: 8) {
                SkeletonView(width: 30, height: 8)
                SkeletonView(width: 60, height: 18)
                SkeletonView(width: 70, height: 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            
            VStack(spacing: 6) {
                SkeletonView(width: 50, height: 8)
                SkeletonView(width: 40, height: 12)
            }
            .padding(.horizontal, 8)
            
            VStack(spacing: 8) {
                SkeletonView(width: 30, height: 8)
                SkeletonView(width: 60, height: 18)
                SkeletonView(width: 70, height: 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
