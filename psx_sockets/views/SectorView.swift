//
//  SectorView.swift
//  psx_sockets
//
//  Created by sarim khan on 27/08/2025.
//

import SwiftUI

struct SectorView: View {
    
    @State private var psxViewModel:PsxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    
    var body: some View {
        VStack{
            switch psxViewModel.psxSector {
            case .initial:
                ProgressView()
            case .loading:
                ProgressView()
            case .loaded(let response):
                List {
                    
                    ForEach(Array(response.data.keys),id:\.self) { key in
                            
                        Section(header:Text(key)) {
                            VStack(alignment:.leading){
                                SectorTileView(title: "Total volume", subtitle: Double(response.data[key]?.totalVolume ?? 0))
                                SectorTileView(title: "Total value", subtitle: Double(response.data[key]?.totalValue ?? 0))
                                SectorTileView(title: "Winners", subtitle: Double(response.data[key]?.gainers ?? 0))
                                SectorTileView(title: "Losers", subtitle: Double(response.data[key]?.losers ?? 0))
                                SectorTileView(title: "Change%", subtitle: Double(response.data[key]?.avgChangePercent ?? 0))


                                }
                               
                            }
                        }
                    
                   
                    
                }
            case .error(let errorMessage):
                Text(errorMessage)
            }
        }
        .navigationTitle("Sectors")
        .task{
          await psxViewModel.getPsxSector()
        }
    }
    
    
    
    
    
}

struct SectorTileView: View {
    var title:String
    var subtitle:Double
    var body: some View {
        HStack{
            Text("\(title): ")
                .font(.headline)
            Text(subtitle,format: .number.precision(.fractionLength(4)))
                .font(.subheadline)
        }
    }
}





#Preview {
    SectorView()
}
