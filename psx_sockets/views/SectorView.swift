//
//  SectorView.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import SwiftUI

struct SectorView: View {
    
    @State private var psxViewModel: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    @Environment(SectorNavigation.self) private var appNavigation
    
    var body: some View {
        List {
            switch psxViewModel.psxSector {
            case .initial:
                ProgressView("Loading sectors...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                
            case .loading:
                ProgressView("Loading sectors...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                
            case .loaded(let response):
                if response.data.isEmpty {
                    emptyStateView
                } else {
                    ForEach(Array(response.data.keys.sorted()), id: \.self) { key in
                        SectorListView(
                            sectorName: key,
                            data: response.data[key]!
                        )
                        .onTapGesture {
                            appNavigation.push(route: SectorNavigationEnums.sectorDetail(sector: response.data[key]!,sectorName: key))
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
            case .error(let errorMessage):
                errorStateView(message: errorMessage)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Market Sectors")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .task {
            await psxViewModel.getPsxSector()
        }
        .refreshable {
            await psxViewModel.getPsxSector()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .padding()
            
            Text("No Sector Data")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Sector information is currently unavailable")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .listRowSeparator(.hidden)
    }
    
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .padding()
            
            Text("Unable to Load")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}

struct SectorListView: View {
    let sectorName: String
    let data: SectorDataModel
    
    var body: some View {
        HStack(spacing: 8) {
            // Sector name with icon
            HStack(spacing: 6) {
                Circle()
                    .fill(sectorColor)
                    .frame(width: 8, height: 8)
                
                Text(sectorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Gainers/Losers indicators
            HStack(spacing: 6) {
                IndicatorPill(
                    count: data.gainers,
                    color: .green,
                    icon: "arrow.up"
                )
                
                IndicatorPill(
                    count: data.losers,
                    color: .red,
                    icon: "arrow.down"
                )
            }
            
            // Percentage change
            Text(data.avgChangePercent, format: .percent.precision(.fractionLength(1)))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(data.avgChangePercent >= 0 ? .green : .red)
                .frame(minWidth: 50, alignment: .trailing)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
    // Color based on sector name (optional)
     private var sectorColor: Color {
         let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
         let index = abs(sectorName.hashValue) % colors.count
         return colors[index]
     }
 }

struct IndicatorPill: View {
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
        .foregroundColor(color)
    }
}


struct SectorCardView: View {
    let sectorName: String
    let data: SectorDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(sectorName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Change indicator
                HStack(spacing: 6) {
                    Image(systemName: data.avgChangePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                        .foregroundColor(data.avgChangePercent >= 0 ? .green : .red)
                    
                    Text(data.avgChangePercent, format: .percent.precision(.fractionLength(2)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(data.avgChangePercent >= 0 ? .green : .red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill((data.avgChangePercent >= 0 ? Color.green : Color.red).opacity(0.1))
                )
            }
            
            // Metrics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SectorMetricView(
                    title: "Total Volume",
                    value: Double(data.totalVolume),
                    valueColor: .blue,
                    icon: "chart.bar.fill"
                )
                
                SectorMetricView(
                    title: "Total Value",
                    value: data.totalValue,
                    valueColor: .purple,
                    icon: "dollarsign.circle.fill"
                )
                
                SectorMetricView(
                    title: "Winners",
                    value: Double(data.gainers),
                    valueColor: .green,
                    icon: "arrow.up.right.circle.fill"
                )
                
                SectorMetricView(
                    title: "Losers",
                    value: Double(data.losers),
                    valueColor: .red,
                    icon: "arrow.down.right.circle.fill"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

struct SectorMetricView: View {
    let title: String
    let value: Double
    let valueColor: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(valueColor)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Text(formatValue(value, for: title))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(valueColor.opacity(0.05))
        )
    }
    
    private func formatValue(_ value: Double, for title: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        
        switch title {
        case "Total Volume", "Total Value":
            // Format large numbers with abbreviations
            if value >= 1_000_000_000 {
                return String(format: "%.2fB", value / 1_000_000_000)
            } else if value >= 1_000_000 {
                return String(format: "%.2fM", value / 1_000_000)
            } else if value >= 1_000 {
                return String(format: "%.2fK", value / 1_000)
            } else {
                return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
            }
            
        case "Winners", "Losers":
            // Integer formatting for counts
            return "\(Int(value))"
            
        case "Change%":
            // Percentage formatting
            return "\(value >= 0 ? "+" : "")\(String(format: "%.2f", value))%"
            
        default:
            return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }
}

#Preview {
    NavigationView {
        SectorView()
    }
}
