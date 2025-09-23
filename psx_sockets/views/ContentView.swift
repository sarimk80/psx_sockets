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
    
    
    var body: some View {
        Group {
            ScrollView {
                HStack(){
                    IndexView(psxWebSocket: webSocketManager)
                    Spacer()
                    
                }
                .padding(.bottom)
                
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
            .padding()
            
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await psxViewModel.getPsxMarketStats()
            await webSocketManager.getMarketUpdate(tickers: ["KSE100","ALLSHR","KMI30","PSXDIV20","KSE30","MII30"])
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
    
    var body: some View {
        if psxWebSocket.portfolioUpdate.isEmpty{
            ProgressView()
        }else{
            TabView{
                
                ForEach(psxWebSocket.portfolioUpdate,id:
                            \.symbol) { result in
                    VStack(alignment:.leading){
                        HStack{
                            Text(result.symbol )
                                .font(.headline)
                            Text(result.tick.st)
                                .font(.subheadline)
                        }
                        HStack{
                            Text("Current Price: ")
                                .font(.subheadline)
                            Text(result.tick.c,format: .number.precision(.fractionLength(2)))
                                .contentTransition(.numericText())
                                .font(.headline)
                            
                            
                        }
                        Text("Change: \(result.tick.ch,specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundStyle(result.tick.ch > 0 ? .green : .red)
                        
                        Text("Open: \(result.tick.o ,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                        Text("High: \(result.tick.h ,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                        Text("Low: \(result.tick.l ,format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                        
                    }
                    .frame(maxWidth:.infinity,alignment:.leading)
                }
            }
                            .tabViewStyle(.page)
                            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                            .frame(height: 150)
                            
            }
            
        }
    }
    
    
    
    
    #Preview {
        ContentView()
    }
