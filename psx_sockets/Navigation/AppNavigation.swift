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

enum PortfolioNavigationEnums:Hashable{
    case tickerDetail(symbol:String)
    case addTickerVolume(symbol:String)
}

enum SectorNavigationEnums:Hashable{
    case sectorDetail(sector:SectorDataModel,sectorName:String)
    case tickerDetail(symbol:String)
}

@MainActor
@Observable
class AppNavigation{
    var tickerNavigation = NavigationPath()
}


@MainActor
@Observable
class PortfolioNavigation{
  var portfolioNav = NavigationPath()
    
    func push(route:PortfolioNavigationEnums) {
        portfolioNav.append(route)
    }
    
    func pop()  {
        portfolioNav.removeLast()
    }
    
    func root(){
        portfolioNav = NavigationPath()
    }
}

@MainActor
@Observable
class SectorNavigation{
    var sectorNav = NavigationPath()
    
    func push(route:SectorNavigationEnums){
        sectorNav.append(route)
    }
    
    func pop(){
        sectorNav.removeLast()
    }
    
    func root(){
        sectorNav = NavigationPath()
    }
}
