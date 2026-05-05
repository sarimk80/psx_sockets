import SwiftUI

struct EtfView: View {
    
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Environment(MoreNavigation.self) private var moreNavigation
    
    var body: some View {
            contentView
                .navigationTitle("ETFs")
                .navigationBarTitleDisplayMode(.large)
                .task {
                    if case AllEtfEnums.initial = psxViewModel.allEtfEnum{
                        await psxViewModel.getAllEtfData()
                    }
                }
        
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch psxViewModel.allEtfEnum {
            
        case .initial, .loading:
            SkeletonState()
        case .loaded(_, let groupData):
            List {
                
                // 🔹 Header Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exchange Traded Funds")
                            .font(.title2.bold())
                        
                        Text("Browse all available ETFs listed on PSX. ETFs are grouped by category to help you explore fund types easily.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                
                // 🔹 ETF Groups
                ForEach(groupData.keys.sorted(), id: \.self) { key in
                    if let value = groupData[key] {
                        Section(header:
                                    Text(key)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        ) {
                            ForEach(value, id: \.id) { etf in
                                EtfRowView(etf: etf)
                                    .onTapGesture {
                                        moreNavigation.push(route: .etfDetailView(indexName: etf.etfName,etf:etf))
                                    }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
        case .error(let errorMessage):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text("Something went wrong")
                    .font(.headline)
                
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Retry") {
                    Task {
                        await psxViewModel.getAllEtfData()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct EtfRowView: View {
    
    let etf: Etf
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(etf.etfName)
                    .font(.headline)
                
                Spacer()
                
                Text(etf.type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
            }
            
            Text(etf.fullName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Label("Fund Size: \(etf.fundSize)", systemImage: "chart.bar.fill")
                Spacer()
                Label("Market Cap: \(etf.marketCap)", systemImage: "building.columns")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct SkeletonState:View {
    
    var body: some View{
        List {
            
            // Header Skeleton
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonView(width: 220, height: 20)
                    SkeletonView(width: .infinity, height: 14)
                    SkeletonView(width: .infinity, height: 14)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
            
            // Fake Groups
            ForEach(0..<3, id: \.self) { _ in
                Section(header:
                            SkeletonView(width: 140, height: 16)
                ) {
                    ForEach(0..<4, id: \.self) { _ in
                        EtfRowSkeletonView()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct EtfRowSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                SkeletonView(width: 140, height: 18)
                Spacer()
                SkeletonView(width: 60, height: 22)
                    .clipShape(Capsule())
            }
            
            SkeletonView(width: .infinity, height: 14)
            
            HStack {
                SkeletonView(width: 120, height: 12)
                Spacer()
                SkeletonView(width: 120, height: 12)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SkeletonView: View {
    
    var width: CGFloat?
    var height: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.2))
            .frame(
                maxWidth: width == .infinity ? .infinity : width,
                minHeight: height,
                maxHeight: height
            )
            .overlay(
                shimmer
            )
            .clipped()
    }
    
    private var shimmer: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.6),
                    Color.clear
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(20))
            .offset(x: isAnimating ? size.width : -size.width)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
        }
    }
}
