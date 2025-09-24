//
//  ContentView.swift
//  psx_sockets
//
//  Created by sarim khan on 18/07/2025.
//

import SwiftUI


enum StockerEnums:String,Identifiable{
    case Active
    case Lossers
    
    var id:Self{self}
}

struct ContentView: View {
    
    @State private var stockerEnums:StockerEnums = .Active
    
    @State private var psxViewModel:PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    @Environment(AppNavigation.self) private var appNavigation
    @Environment(WebSocketManager.self) private var webSocketManager
    
    @State private var selectedTab:Int = 0
    
    
    var body: some View {
        
        List {
            VStack(spacing: 16) {
                IndexView(psxWebSocket: webSocketManager,selectedTab: $selectedTab)
                
                HStack{
                    ForEach(0..<6,id: \.self) { index in
                        HStack{
                            Circle()
                                .fill(index == selectedTab ? Color("AccentColor"):Color.gray.opacity(0.3))
                                .frame(width: 10,height: 10)
                        }
                        
                    }
                }
                
                
                Picker("My Picker", selection: $stockerEnums) {
                    Text("Gainers").tag(StockerEnums.Active)
                    Text("Lossers").tag(StockerEnums.Lossers)
                }
                .pickerStyle(.segmented)
                
                
                switch psxViewModel.psxStats {
                case .initial:
                    ProgressView()
                case .loading:
                    ProgressView()
                case .loaded(let data):
                    switch stockerEnums {
                    case .Active:
                        ForEach(data.data.topGainers,id: \.symbol){ticker in
                            TileView(ticker: ticker)
                                .onTapGesture {
                                    appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: ticker.symbol))
                                }
                        }
                    case .Lossers:
                        ForEach(data.data.topLosers,id: \.symbol){ticker in
                            TileView(ticker: ticker)
                                .onTapGesture {
                                    appNavigation.tickerNavigation.append(TickerDetailRoute.tickerDetail(symbol: ticker.symbol))
                                }
                        }
                    }
                case .error(let errorMessage):
                    Text(errorMessage)
                }
            
        
            
        }
        .listRowSeparator(.hidden)
        
    }
        .listStyle(.plain)
        .navigationTitle("Home")
        .task {
            await psxViewModel.getPsxMarketStats()
            await webSocketManager.getMarketUpdate(tickers: ["KSE100","ALLSHR","KMI30","PSXDIV20","KSE30","MII30"],market: "IDX")
        }
    
    
}
}

struct TileView: View {
    var ticker:Top
    var body: some View {
        HStack {
            Text(ticker.symbol)
                .font(.headline)
            
            Spacer()
            VStack(alignment:.trailing){
                Text(ticker.price.description)
                    .font(.headline)
                HStack{
                    Text(ticker.change,format: .number.precision(.fractionLength(2)))
                        .font(.subheadline)
                        .foregroundStyle(ticker.change > 0 ? .green : .red)
                    Text(ticker.changePercent,format: .number.precision(.fractionLength(2)))
                        .font(.subheadline)
                        .foregroundStyle(ticker.changePercent > 0 ? .green : .red)
                }
                
            }
            
        }
    }
}


struct StatsView: View {
    
    var psxViewModel:PsxViewModel
    var body: some View {
        VStack {
            switch psxViewModel.psxStats {
            case .initial:
                ProgressView()
            case .loading:
                ProgressView()
            case .loaded(let data):
                VStack(alignment:.leading) {
                    Text( "Gainers count:  \(data.data.gainers)")
                    Text( "Losers count:  \(data.data.losers)")
                    Text( "Total trade count:  \(data.data.totalTrades)")
                    Text( "Total volume count:  \(data.data.totalVolume)")
                }
            case .error(let errorMessage):
                Text(errorMessage)
            }
        }
    }
}


struct IndexView: View {
    
    var psxWebSocket:WebSocketManager
    @Binding var selectedTab:Int
    
    var body: some View {
        if psxWebSocket.portfolioUpdate.isEmpty{
            ProgressView()
        }else{
            TabView(selection:$selectedTab){
                ForEach(psxWebSocket.portfolioUpdate.enumerated(),id:
                            \.element) { index,result in
                    TickerView(ticker: result)
                        .frame(maxWidth:.infinity,alignment:.leading)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .frame(height: 160)
            
        }
        
    }
}



struct TickerView: View {
    var ticker: TickerUpdate?
    var body: some View {
        VStack(alignment:.leading){
            HStack(alignment:.top){
                Text(ticker?.symbol ?? "" )
                    .font(.headline)
                Text(ticker?.tick.st ?? "")
                    .font(.subheadline)
            }
            HStack{
                Text("Current Price: ")
                    .font(.subheadline)
                Text(ticker?.tick.c ?? 0.0,format: .number.precision(.fractionLength(2)))
                    .contentTransition(.numericText())
                    .font(.headline)
                
                
            }
            Text("Change: \(ticker?.tick.ch ?? 0.0,specifier: "%.2f")")
                .font(.subheadline)
                .foregroundStyle(ticker?.tick.ch ?? 0.0 > 0 ? .green : .red)
            HStack{
                VStack(alignment:.leading){
                    
                    Text("Open: \(ticker?.tick.o ?? 0.0,format: .number.precision(.fractionLength(2)))")
                        .font(.caption)
                    Text("High: \(ticker?.tick.h ?? 0.0,format: .number.precision(.fractionLength(2)))")
                        .font(.caption)
                    Text("Low: \(ticker?.tick.l ?? 0.0,format: .number.precision(.fractionLength(2)))")
                        .font(.caption)
                }
                Spacer()
                if ticker?.market != "IDX" {
                    
                    VStack(alignment:.trailing){
                        Text("Bid: \(ticker?.tick.bp ?? 0.0,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                        Text("Bid volume: \(ticker?.tick.bv ?? 0,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                        Text("Ask: \(ticker?.tick.ap ?? 0.0,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                        Text("Ask volume: \(ticker?.tick.av ?? 0,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                    }
                }
                
                
            }
            
            
        }
    }
}



#Preview {
    ContentView()
}
