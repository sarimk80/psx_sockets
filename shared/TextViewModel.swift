//
//  TextViewModel.swift
//  psx_sockets
//
//  Created by sarim khan on 26/03/2026.
//

import Foundation
import Combine

@MainActor
@Observable
class TextViewModel {
    var name:String = ""
    
    func updateName(myName:String)  {
        name = myName
    }
    
}
