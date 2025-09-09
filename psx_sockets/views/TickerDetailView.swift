//
//  TickerDetailView.swift
//  psx_sockets
//
//  Created by sarim khan on 28/08/2025.
//

import SwiftUI
import Charts

struct TickerDetailView: View {
    var symbol:String
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    //@State private var psxSocketManager = WebSocketManager()
    
    @Environment(WebSocketManager.self) private var psxSocketManager
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading){
                IndexView(psxWebSocket: psxSocketManager)
                    .padding(.horizontal,16)
                
                KlineChart(psxSocketManager: psxSocketManager)
                    .padding(.horizontal,16)
                
                switch psxViewModel.psxCompany {
                case .initial:
                    ProgressView()
                case .loading:
                    ProgressView()
                case .loaded(let company, let dividend, let fundamental):
                    VStack(alignment:.leading){
                        Text("About")
                            .font(.headline)
                            .padding(.vertical,8)
                            .padding(.horizontal,16)
                        Text(company.data.businessDescription)
                            .padding(.all,8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.26), radius: 6)
                            )
                            .padding(.horizontal,16)
                            .frame(width: UIScreen.main.bounds.width)
                            
                        
                        
                        Text("Fundamentals")
                            .font(.headline)
                            .padding(.vertical,8)
                            .padding(.horizontal,16)
                        Grid(alignment:.leading){
                            CompanyFundamentals(title: "Free float:", subTitle: company.data.financialStats.freeFloat.raw)
                            CompanyFundamentals(title: "Free float percentage:", subTitle: company.data.financialStats.freeFloatPercent.raw)
                            CompanyFundamentals(title: "Market Cap:", subTitle: company.data.financialStats.marketCap.raw)
                            CompanyFundamentals(title: "Total share:", subTitle: company.data.financialStats.shares.raw)
                            CompanyFundamentals(title: "Change %:", subTitle: fundamental.data.changePercent.formatted(.number.precision(.fractionLength(2))))
                            CompanyFundamentals(title: "Dividend Yield:", subTitle: fundamental.data.dividendYield.description)
                            CompanyFundamentals(title: "Sharia Complient:", subTitle: fundamental.data.isNonCompliant.description)
                            CompanyFundamentals(title: "P/E ratio:", subTitle: fundamental.data.peRatio.formatted(.number.precision(.fractionLength(2))))
                            CompanyFundamentals(title: "Yearly Change:", subTitle: fundamental.data.yearChange.formatted(.number.precision(.fractionLength(2))))
                            CompanyFundamentals(title: "Volume Average yearly:", subTitle: fundamental.data.volume30Avg.description)
                        }
                        
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.26), radius: 6)
                        )
                        .padding(.horizontal,16)
                        .frame(width: UIScreen.main.bounds.width)
                        
                        
                           
                        
                        Text("Key Person")
                            .font(.headline)
                            .padding(.vertical,8)
                            .padding(.horizontal,16)
                        VStack{
                            ForEach(company.data.keyPeople,id: \.position){div in
                                    HStack{
                                        Text(div.position)
                                            .font(.headline)
                                        Spacer()
                                        Text(div.name)
                                            .font(.subheadline)
                                    }
                                    .padding([.horizontal,.vertical],8)
                                
                                
                            }
                        }
                        
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.26), radius: 6)
                        )
                        .padding(.horizontal,16)
                        .frame(width: UIScreen.main.bounds.width)
                            
                        
                        Text("Dividend")
                            .font(.headline)
                            .padding(.vertical,8)
                            .padding(.horizontal,16)
                        Grid {
                            GridRow {
                                Text("Symbol")
                                Text("Payment date")
                                Text("Dividend")
                            }
                            .bold()
                            Divider()
                            ForEach(dividend.data,id: \.paymentDate){div in
                                GridRow {
                                    Text(div.symbol)
                                    Text(div.paymentDate)
                                    Text(String(describing: div.amount))
                                }
                                
                            }
                        }
                        
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.26), radius: 6)
                        )
                        .padding(.horizontal,16)
                        .frame(width: UIScreen.main.bounds.width)
                        
                        
                    }
                case .error(let errorMessage):
                    Text(errorMessage)
                }
            }
        }
       
        .navigationTitle(symbol)
        .task {
            await psxViewModel.getCompanyDetail(symbol: symbol)
           await psxSocketManager.unSubscribeStream(symbol: symbol,market: "REG")
            psxSocketManager.KlineSteam(symbol: symbol)
        }
    }
}


struct CompanyFundamentals: View {
    
    var title:String
    var subTitle:String
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(subTitle)
        }
        .padding()
    }
}

struct KlineChart: View {
    
    var psxSocketManager: WebSocketManager
    
    @State private var scrollPosition: Date = .now
    
    var body: some View {
        
        if let kline = psxSocketManager.klineModel{
            
            
            
            Chart {
                
                ForEach(kline.klines){data in
                    LineMark(x: .value("Date", data.adjustedDate), y: .value("Price", data.close))
                        .foregroundStyle(Color.green)
                    
                    AreaMark(x: .value("Date", data.adjustedDate), y: .value("Price", data.close))
                        .foregroundStyle(.linearGradient(colors: [ Color.green.opacity(0.3),Color.green.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    
                    
                }
                
            }
            .clipShape(Rectangle())
            .chartYScale(domain: [kline.klines.map({$0.close}).min() ?? 0.0, kline.klines.map({$0.close}).max() ?? 0.0])
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $scrollPosition)
            .chartXVisibleDomain(length: 60 * 60 * 24 * 30)
            .frame(height:350)
            .onAppear {
                self.scrollPosition = kline.klines.map({ $0.adjustedDate }).last ?? .now
            }
            
        }else{
            ProgressView()
        }
    }
}





#Preview {
    TickerDetailView(symbol: "DCR")
}
