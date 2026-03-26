//
//  ContentView.swift
//  psx_socket_mac
//
//  Created by sarim khan on 26/03/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var textVm: TextViewModel = TextViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, \(textVm.name)")
        }
        .onAppear(perform: {
            textVm.updateName(myName: "Sarim")
        })
        .padding()
    }
}

#Preview {
    ContentView()
}
