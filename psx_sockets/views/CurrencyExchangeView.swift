//
//  CurrencyExchangeView.swift
//  psx_sockets
//
//  Created by sarim khan on 04/06/2026.
//

import SwiftUI


struct CurrencyExchangeView: View {
    
    @State private var searchText: String = ""
    @State private var currencyFilter: CurrencyFilter = .All
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @State private var showBottomSheet:Bool = false
    @State private var showWeelBottomSheet:Bool = false
    @State private var toSelectedCurrency:CurrencyResponse?
    @State private var fromSelectedCurrency:CurrencyResponse?
    @State private var currencyNavigation:CurrencyNavigation = CurrencyNavigation()
    @State private var amount:String = ""
    
    
    
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
                    self.showBottomSheet.toggle()
                } label: {
                    Image(systemName: "arrow.left.arrow.right.circle")
                }
            }
        }
        .task {
            await psxViewModel.getAllCurrencyExchange()
        }
        .sheet(isPresented: $showBottomSheet) {
            NavigationStack(path: $currencyNavigation.currencyNav) {
                bottomSheetView()
                    .presentationDetents([.fraction(0.8)])
                    .presentationBackground(Color(.tertiarySystemBackground))
                    .navigationDestination(for: CurrencyNavigationEnums.self) { destination in
                        switch destination {
                        case .openCurrencySheet(let currencyExchange,let isFromCurrency):
                            WheelSheetView(currencyExchange: currencyExchange) { response in
                                currencyNavigation.pop()
                                if(isFromCurrency){
                                    fromSelectedCurrency = response
                                }else{
                                    toSelectedCurrency = response
                                }
                            }
                            
                        }
                    }
            }
            
            
        }
        
        .onChange(of: currencyFilter) { oldValue, newValue in
            
            psxViewModel.filteredItems(currencyFilter: newValue, searchText: searchText)
            
        }
        .onChange(of: searchText) { oldValue, newValue in
            psxViewModel.filteredItems(currencyFilter: currencyFilter, searchText:newValue)
            
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
            //            let items = psxViewModel.filteredItems(currencyFilter: currencyFilter, searchText: searchText)
            if psxViewModel.currencyExchange.isEmpty {
                emptyStateView
            } else {
                currencyList(items: psxViewModel.currencyExchange)
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
    
    private func bottomSheetView() -> some View {
        VStack{
            VStack(alignment:.leading,spacing:8){
                Text("From")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button {
                    currencyNavigation.push(
                        route: .openCurrencySheet(
                            currencyExchange: psxViewModel.currencyExchange,
                            isFromCurrency: true
                        )
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fromSelectedCurrency?.currencyName ?? "Select currency")
                                .font(.headline)
                            
                            if(fromSelectedCurrency != nil){
                                Text(fromSelectedCurrency?.country ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title2.bold())
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Button {
                swap(&fromSelectedCurrency, &toSelectedCurrency)
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.system(size: 34))
            }

            
            VStack(alignment: .leading, spacing: 8) {
                Text("To")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button {
                    currencyNavigation.push(
                        route: .openCurrencySheet(
                            currencyExchange: psxViewModel.currencyExchange,
                            isFromCurrency: false
                        )
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(toSelectedCurrency?.currencyName ?? "Select currency")
                                .font(.headline)
                            
                            if(toSelectedCurrency != nil) {
                                Text(toSelectedCurrency?.country ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 8) {
                Text("Converted Amount")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(
                    ((Double(amount) ?? 0) *
                     ((fromSelectedCurrency?.currency ?? 1) / (toSelectedCurrency?.currency ?? 1))),
                    format: .number.precision(.fractionLength(2))
                )
                .font(.system(size: 34, weight: .bold))
                
                Text(toSelectedCurrency?.currencyName ?? "")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20))
                   
        }
        .padding()
        .navigationTitle("Select currency")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    self.showBottomSheet.toggle()
                } label: {
                    Image(systemName: "xmark")
                }
                
            }
        }
    }
    
}

struct WheelSheetView:View {
    
    var currencyExchange:[CurrencyResponse]
    var onSubmit: (CurrencyResponse) -> Void
    
    @State private var searchText:String = ""
    
    private var filteredCurrencies: [CurrencyResponse] {
        if searchText.isEmpty {
            return currencyExchange
        }
        
        return currencyExchange.filter {
            $0.country.localizedCaseInsensitiveContains(searchText) ||
            $0.currencyName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredCurrencies, id: \.currencyName) { data in
            VStack(alignment:.leading){
                Text(data.country)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(data.currencyName)
                    .font(.caption)
            }
            .onTapGesture {
                onSubmit(data)
            }
            
                
        }
        .listStyle(.plain)
        .navigationTitle("Search currency")
        .searchable(text: $searchText,placement: .navigationBarDrawer(displayMode: .always)  ,prompt: "Search Currency")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}


// MARK: - Currency Row View

struct CurrencyRowView: View {
    let item: CurrencyResponse
    
    var body: some View {
        HStack(spacing: 12) {
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
