//
//  AppNavigation.swift
//  psx_sockets
//
//  Created by sarim khan on 28/08/2025.
//

import Foundation
import SwiftUI
import Combine

enum TickerDetailRoute:Hashable {
    case tickerDetail(symbol:String)
    case corporationDetail(sectionName:CorporationEnum  ,data:[DividendModel])
}

@Observable
class AppNavigation{
    var tickerNavigation = NavigationPath()
}
