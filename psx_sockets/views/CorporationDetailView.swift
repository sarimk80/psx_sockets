//
//  CorporationDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 24/11/2025.
//

import SwiftUI

struct CorporationDetailView: View {
    var corporation: CorporationEnum
    var data: [DividendModel]
    
    private var filteredData: [DividendModel] {
        switch corporation {
        case .Dividend:
            return data.filter { $0.dividend != "-" }
        case .Eps:
            return data.filter { $0.eps != "-" }
        case .ProfitLoss:
            return data.filter { $0.profitLossAfterTax != "-" || $0.profitLossBeforeTax != "-" }
        case .Meeting:
            return data.filter { $0.boardMeeting != "-" }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: getIcon())
                            .font(.title2)
                            .foregroundColor(getColor())
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(corporation.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("\(filteredData.count) announcements")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Text(getDescription())
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Content Section
                if filteredData.isEmpty {
                    emptyStateView
                } else {
                        ForEach(filteredData, id: \.id) { result in
                            CorporationDetailCard(result: result, corporation: corporation)
                                .padding(.horizontal)
                        
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        //.navigationBarTitleDisplayMode(.inline)
        .navigationTitle(corporation.rawValue)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: getIcon())
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No \(corporation.rawValue) Data")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("There are currently no \(corporation.rawValue.lowercased()) announcements")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding(.horizontal, 40)
    }
    
    private func getIcon() -> String {
        switch corporation {
        case .Dividend: return "gift"
        case .Eps: return "chart.line.uptrend.xyaxis"
        case .ProfitLoss: return "dollarsign.circle"
        case .Meeting: return "person.2"
        }
    }
    
    private func getColor() -> Color {
        switch corporation {
        case .Dividend: return .green
        case .Eps: return .orange
        case .ProfitLoss: return .purple
        case .Meeting: return .blue
        }
    }
    
    private func getDescription() -> String {
        switch corporation {
        case .Dividend:
            return "Recent dividend announcements and payment details from listed companies"
        case .Eps:
            return "Earnings per share announcements showing company profitability"
        case .ProfitLoss:
            return "Profit and loss statements showing company financial performance"
        case .Meeting:
            return "Upcoming and recent board meetings and corporate gatherings"
        }
    }
}

struct CorporationDetailCard: View {
    let result: DividendModel
    let corporation: CorporationEnum
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Company Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.company)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if result.yearEnded != "-" {
                        Text(result.yearEnded)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                }
                
                Spacer()
                
                // Status Indicator
                statusIndicator
            }
            
            // Content based on corporation type
            switch corporation {
            case .Dividend:
                dividendContent
            case .Eps:
                epsContent
            case .ProfitLoss:
                profitLossContent
            case .Meeting:
                meetingContent
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private var statusIndicator: some View {
        Group {
            switch corporation {
            case .Dividend:
                Circle()
                    .fill(result.dividend == "-" ? Color.gray : Color.green)
                    .frame(width: 12, height: 12)
            case .Eps:
                let isPositive = !result.eps.contains("(") && result.eps != "-"
                Circle()
                    .fill(result.eps == "-" ? Color.gray : (isPositive ? Color.green : Color.red))
                    .frame(width: 12, height: 12)
            case .ProfitLoss:
                let isProfit = !result.profitLossAfterTax.contains("(") && result.profitLossAfterTax != "-"
                Circle()
                    .fill(result.profitLossAfterTax == "-" ? Color.gray : (isProfit ? Color.green : Color.red))
                    .frame(width: 12, height: 12)
            case .Meeting:
                Circle()
                    .fill(result.boardMeeting == "-" ? Color.gray : Color.blue)
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    private var dividendContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if result.dividend != "-" {
                HStack {
                    Image(systemName: "gift")
                        .foregroundColor(.green)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dividend")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.dividend)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if result.date != "-" {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Payment Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.date)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private var epsContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if result.eps != "-" {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(getEpsColor())
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EPS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.eps)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(getEpsColor())
                    }
                }
            }
        }
    }
    
    private var profitLossContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if result.profitLossAfterTax != "-" {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(getProfitLossColor())
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Profit/Loss After Tax")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.profitLossAfterTax)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(getProfitLossColor())
                    }
                }
            }
            
            if result.profitLossBeforeTax != "-" {
                HStack {
                    Image(systemName: "dollarsign.square")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Profit/Loss Before Tax")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.profitLossBeforeTax)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private var meetingContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if result.boardMeeting != "-" {
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Board Meeting")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(result.boardMeeting)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private func getEpsColor() -> Color {
        let isPositive = !result.eps.contains("(") && result.eps != "-"
        return isPositive ? .green : .red
    }
    
    private func getProfitLossColor() -> Color {
        let isProfit = !result.profitLossAfterTax.contains("(") && result.profitLossAfterTax != "-"
        return isProfit ? .green : .red
    }
}

#Preview {
    NavigationView {
        CorporationDetailView(
            corporation: .Dividend,
            data: [
                DividendModel(
                    company: "First Treet Manufacturing Modaraba",
                    dividend: "15%(i) (D)",
                    date: "27/11/2025  - 29/11/2025",
                    boardMeeting: "-",
                    eps: "-",
                    profitLossBeforeTax: "-",
                    profitLossAfterTax: "-",
                    yearEnded: "-"
                ),
                DividendModel(
                    company: "Honda Atlas Cars (Pakistan) Limited",
                    dividend: "-",
                    date: "-",
                    boardMeeting: "-",
                    eps: "11.00",
                    profitLossBeforeTax: "2,583.038",
                    profitLossAfterTax: "1,570.614",
                    yearEnded: "30/09/2025(HYR)"
                )
            ]
        )
    }
}
