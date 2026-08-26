//
//  MetalView.swift
//  psx_sockets
//

import SwiftUI

struct MetalView: View {
    
    @State private var psxViewModel = PsxViewModel(psxServiceManager: PsxServiceManager())
    @Environment(MoreNavigation.self) private var moreNavigation
    
    var body: some View {
        ScrollView {
            
            switch psxViewModel.metalListEnum {
            case .initial, .loading:
                Section {
                    ForEach(Commodity.mock,id:\.id) { result in
                                                
                            HStack(spacing: 16) {
                                
                                Image(systemName: result.icon)
                                    .font(.title2)
                                    .foregroundStyle(result.iconColor.opacity(0.95))
                                    .frame(width: 45, height: 45)
                                    .background(result.iconColor.opacity(0.15))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.name)
                                        .font(.headline)
                                    
                                    Text("Tap to view details")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                        .redacted(reason: .placeholder)
                            
                         
                        
                        .padding(.vertical, 8)
                        .padding(.horizontal,8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                    }
                    .padding(.horizontal,8)
                }
            case .loaded(let commodities):
                
                Section {
                    ForEach(commodities,id:\.id) { result in
                                                
                            HStack(spacing: 16) {
                                
                                Image(systemName: result.icon)
                                    .font(.title2)
                                    .foregroundStyle(result.iconColor.opacity(0.95))
                                    .frame(width: 45, height: 45)
                                    .background(result.iconColor.opacity(0.15))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.name)
                                        .font(.headline)
                                    
                                    Text("Tap to view details")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                            
                         
                        
                        .padding(.vertical, 8)
                        .padding(.horizontal,8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .onTapGesture {
                            moreNavigation.push(route: .metalDetail(metal: result.symbol,color: result.iconColor))
                        }
                        
                    }
                } header: {
                    HStack (alignment: .firstTextBaseline){
                        Text("All commodities")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(commodities.count) counts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                
                
                .padding(.horizontal,16)
                .padding(.top,4)
                .padding(.bottom,4)
                
            case .error(let message):
                Text(message)
            }
            
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Commodities")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .task {
            if case MetalListEnums.initial = psxViewModel.metalListEnum{
                await psxViewModel.getAllCommodities()

            }
        }
        
    }
}

#Preview {
    MetalView()
}
