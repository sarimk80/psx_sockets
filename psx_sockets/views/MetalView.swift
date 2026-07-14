//
//  MetalView.swift
//  psx_sockets
//

import SwiftUI

struct MetalView: View {
    
    @Environment(MoreNavigation.self) private var moreNavigation
    
    struct Metal: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
    }

    
    let metals: [Metal] = [
            Metal(name: "Gold",      icon: "crown.fill",              color: .yellow),
            Metal(name: "Silver",    icon: "moon.stars.fill",         color: .gray),
            Metal(name: "Copper",    icon: "bolt.fill",               color: .orange),
            Metal(name: "Platinum",  icon: "diamond.fill",            color: .blue),
            Metal(name: "Palladium", icon: "shield.lefthalf.filled",  color: .purple)
        ]
    

    var body: some View {
            List {
                ForEach(metals, id: \.id) { metal in
                    HStack(spacing: 16) {

                        Image(systemName: metal.icon)
                            .font(.title2)
                            .foregroundStyle(metal.color)
                            .frame(width: 45, height: 45)
                            .background(metal.color.opacity(0.15))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(metal.name)
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
                    .onTapGesture {
                        moreNavigation.push(route: .metalDetail(metal: metal.name))
                    }
                }
            }
            .navigationTitle("Metals")
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        
    }
}

#Preview {
    MetalView()
}
