//
//  SectorDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 23/12/2025.
//

import SwiftUI

struct SectorDetailView: View {
    let sectorName: String
    let data: [SectorStocks]

    var body: some View {
        List(data) { stock in

            HStack(spacing: 16) {

                VStack(alignment: .leading, spacing: 6) {

                    Text(stock.scriptCode)
                        .font(.headline)

                    Text(stock.scriptName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {

                    Text(stock.current)
                        .font(.headline.bold())

                    Text(stock.change)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(changeColor(stock.change))
                }

                Image(systemName: trendIcon(stock.trend))
                    .foregroundStyle(trendColor(stock.trend))
            }

        }
        .navigationTitle(sectorName)
        .listStyle(.insetGrouped)
    }

    private func changeColor(_ value: String) -> Color {
        guard let change = Double(value) else { return .secondary }
        return change >= 0 ? .green : .red
    }

    private func trendColor(_ trend: String) -> Color {
        trend.lowercased() == "increase" ? .green : .red
    }

    private func trendIcon(_ trend: String) -> String {
        trend.lowercased() == "increase"
        ? "arrow.up.right.circle.fill"
        : "arrow.down.right.circle.fill"
    }
}

