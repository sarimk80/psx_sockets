//
//  psx_socketsApp.swift
//  psx_sockets
//
//  Created by sarim khan on 18/07/2025.
//

import SwiftUI
import SwiftData

@main
struct psx_socketsApp: App {
    
    @State private var psxWebSocket = WebSocketManager()
    let container: ModelContainer
    
    init() {
        do{
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: PortfolioModel.self, configurations: configuration)
        }catch(let error){
            fatalError(error.localizedDescription)
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(psxWebSocket)
                
        }
        .modelContainer(for: PortfolioModel.self)
    }
}
