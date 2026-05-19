//
//  ComingSoonView.swift
//  psx_sockets
//
//  Created by sarim khan on 08/05/2026.
//

import SwiftUI

struct ComingSoonView: View {
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Image("coming_soon")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Coming Soon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("We're working on something exciting. Stay tuned for updates!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
           
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Coming Soon")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ComingSoonView()
}
