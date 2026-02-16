//
//  TickerVolumeView.swift
//  psx_sockets
//
//  Created by sarim khan on 18/12/2025.
//

import SwiftUI

struct TickerVolumeView: View {
    let symbol:String
    
    
    @State private var inputText:String = ""
    
    var body: some View {
        VStack{
            Text("Hello, World!")
            TextField("", text: $inputText,prompt: Text("hello"))
        }
       
    }
}

#Preview {
    TickerVolumeView(
        symbol: "EPCL"
    )
}
