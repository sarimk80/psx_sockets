//
//  HomeView.swift
//  psx_socket_mac
//
//  Created by sarim khan on 10/04/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationSplitView {
            List {
                Text("KSE100")
                Text("KSE30")
            }
        } detail: {
            Text("Detail View")
        }

    }
}

#Preview {
    HomeView()
}
