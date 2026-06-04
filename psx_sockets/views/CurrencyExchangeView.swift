//
//  CurrencyExchangeView.swift
//  psx_sockets
//
//  Created by sarim khan on 04/06/2026.
//

import SwiftUI

// MARK: - Currency Row Model (adjust fields to match your actual model)

struct CurrencyExchangeView: View {

    @State private var searchText: String = ""
    @State private var currencyFilter: CurrencyFilter = .All
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            filterChips
            Divider()
            mainContent
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Enter currency or country"
        )
        .navigationTitle("Currency Exchange")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.left.arrow.right.circle")
                }
            }
        }
        .task {
            await psxViewModel.getAllCurrencyExchange()
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CurrencyFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currencyFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                currencyFilter == filter
                                    ? Color.accentColor
                                    : Color(.systemGray5)
                            )
                            .foregroundStyle(
                                currencyFilter == filter ? .white : .primary
                            )
                            .clipShape(Capsule())
                            .animation(.easeInOut(duration: 0.2), value: currencyFilter)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch psxViewModel.currencyExchangeEnum {
        case .initial, .loading:
            loadingView

        case .loaded:
            let items = psxViewModel.filteredItems(currencyFilter: currencyFilter, searchText: searchText)
            if items.isEmpty {
                emptyStateView
            } else {
                currencyList(items: items)
            }

        case .error(let message):
            errorView(message: message)
        }
    }

    // MARK: - Currency List

    private func currencyList(items:[CurrencyResponse])-> some View {
        List(items, id: \.currencyName) { item in
            CurrencyRowView(item: item)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 6, trailing: 8))
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Fetching rates...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No results found")
                .font(.headline)
            Text("Try a different currency name or country.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await psxViewModel.getAllCurrencyExchange() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Currency Row View

struct CurrencyRowView: View {
    let item: CurrencyResponse  // Replace with your actual model type

    var body: some View {
        HStack(spacing: 12) {
            // Flag / Currency Icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 44)
                Text(item.currencyName.prefix(2))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.country)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(item.currencyName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(item.currency,format: .number.precision(.fractionLength(2)))
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("1 PKR = \(item.currency,format:.number.precision(.fractionLength(2))) \(item.currencyName)")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(12)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CurrencyExchangeView()
    }
}
