//
//  TransactionDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 11/03/2026.
//

import SwiftUI

struct TransactionDetailView: View {
    
    @State private var psxVM: PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    let symbol: String
    var body: some View {
        List{
            switch psxVM.transactionDetailEnum {
            case .initial:
                ProgressView()
            case .loading:
                ProgressView()
            case .loaded(let portfolioTickers):
                Section {
                    ForEach(portfolioTickers,id: \.date) { result in
                        PortfolioTile(transaction: result)
                            .contentShape(Rectangle())
                            .onTapGesture {
                            }
                            .listRowInsets(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .padding(.horizontal, 2)
                                    .padding(.vertical, 4)
                            )
                    }
                }
            case .error(let errorMessage):
                ErrorView(message: errorMessage)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(symbol)
        .navigationSubtitle("Transaction history")
        .navigationBarTitleDisplayMode(.large)
        .task {
           await psxVM.getSingleTransactionDetail(ticker: symbol)
        }
    }
}

struct PortfolioTile: View {
    
    let transaction: Transaction
    
    var isBuy: Bool {
        (transaction.status ?? "Buy").lowercased() == "buy"
    }
    
    var totalValue: Double {
        Double(transaction.volume) * (transaction.price ?? 0)
    }
    
        
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        
        if let date = formatter.date(from: self.transaction.date) {
            return date.formatted(
                .dateTime
                    .day()
                    .month(.abbreviated)
                    .year()
            )
        }
        
        return ""
    }
    
    
    var body: some View {
        
        HStack(spacing: 14) {
            
            // Status Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                (isBuy ? Color.green : Color.red).opacity(0.25),
                                (isBuy ? Color.green : Color.red).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                
                Image(systemName: isBuy ? "arrow.down" : "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isBuy ? .green : .red)
            }
            
            
            // Left Info
            VStack(alignment: .leading, spacing: 4) {
                
                Text(transaction.ticker)
                    .font(.headline)
                
                Text("\(transaction.volume) shares @ \(transaction.price ?? 0, format: .number.precision(.fractionLength(2)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            
            Spacer()
            
            
            // Right Info
            VStack(alignment: .trailing, spacing: 4) {
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(totalValue, format: .currency(code: "PKR"))
                    .font(.headline)
                    .foregroundStyle(isBuy ? .green : .red)
            }
        }
        .padding(14)
    }
}

#Preview {
    TransactionDetailView(symbol: "EPCL")
}
