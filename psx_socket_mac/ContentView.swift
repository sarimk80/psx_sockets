//
//  ContentView.swift
//  psx_socket_mac
//
//  Created by sarim khan on 26/03/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var textVm: TextViewModel = TextViewModel()
    
    @State private var selection: String? = "Home"
    
    @State private var visibility = NavigationSplitViewVisibility.doubleColumn
    
    @State private var preferredColumn =
    NavigationSplitViewColumn.content

    
    var body: some View {
        

        
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            List(selection: $selection) {
                Section {
                    NavigationLink(value: "Home") {
                        Label("Indices", systemImage: "house")
                    }
                    NavigationLink(value: "Indicies") {
                        Label("Dividends", systemImage: "gift")
                    }
                    NavigationLink(value: "Meeting") {
                        Label("Meeting", systemImage: "person.2")
                    }
                    NavigationLink(value: "EPS") {
                        Label("EPS", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    NavigationLink(value: "Profit") {
                        Label("Profit/loss", systemImage: "dollarsign.circle")
                    }
                } header: {
                    Text("Home")
                }

                Section {
                    NavigationLink(value: "Portfolio") {
                        Label("Portfolio", systemImage: "scroll")
                    }
                    NavigationLink(value: "Hot") {
                        Label("Hot Stocks", systemImage: "flame")
                    }
                    NavigationLink(value: "Portfolio") {
                        Label("Indistries", systemImage: "scroll")
                    }
                } header: {
                    Text("Stocks")
                }

               
                Section {
                    NavigationLink(value: "Search") {
                        Label("Search", systemImage: "ellipsis.rectangle")
                    }
                    NavigationLink(value: "Settings") {
                        Label("Clear data", systemImage: "ellipsis.rectangle")
                    }
                } header: {
                    Text("More")
                }

                
            }
            .navigationTitle("Menu")
            .navigationSubtitle("More")
            .toolbar {
                ToolbarItem {
                    Image(systemName: "house")
                }
                ToolbarItem {
                    Text("Hello")
                }
            }
        } detail: {
            switch selection {
            case "Portfolio":
                Text("Portfolio detail")
            case "Settings":
                Text("Settings detail")
            default:
                Text("Home detail")
            }
        }
    }
}

#Preview {
    ContentView()
}
