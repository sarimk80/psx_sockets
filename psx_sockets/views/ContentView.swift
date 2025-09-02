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
    
    @State private var webSocketManager:WebSocketManager = WebSocketManager()
    
    @Environment(AppNavigation.self) private var appNavigation
    
    
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
            webSocketManager.getSymbolDetailRealTime(symbol: "KSE100")
        }
        .onDisappear {
            webSocketManager.unSubscribeStream(symbol: "KSE100")
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
        VStack(alignment:.leading){
            if let tickerUpdate = psxWebSocket.tickerUpdate{
                VStack(alignment:.leading){
                    HStack{
                        Text(psxWebSocket.tickerUpdate?.symbol ?? "" )
                            .font(.headline)
                        Text(psxWebSocket.tickerUpdate?.tick.st ?? "")
                            .font(.subheadline)
                    }
                    HStack{
                        Text("Current Price: \(psxWebSocket.tickerUpdate?.tick.c ?? 0.0,format: .number.precision(.fractionLength(2)))")
                            .font(.subheadline)
                        
                    }
                    Text("Change: \(tickerUpdate.tick.ch,specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundStyle(tickerUpdate.tick.ch > 0 ? .green : .red)
                    
                    Text("Open: \(psxWebSocket.tickerUpdate?.tick.o ?? 0.0,format: .number.precision(.fractionLength(2)))")
                        .font(.caption)
                    Text("High: \(psxWebSocket.tickerUpdate?.tick.h ?? 0.0,format: .number.precision(.fractionLength(2)))")
                        .font(.caption)
                    Text("Low: \(psxWebSocket.tickerUpdate?.tick.l ?? 0.0,format: .number.precision(.fractionLength(2)))")
                        .font(.caption)

                    
                   
                    
                }
            }else{
                ProgressView()
            }
        }
    }
}




#Preview {
    ContentView()
}
