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
    case indexDetail(indexName:IndexEnums)
}

enum PortfolioNavigationEnums:Hashable{
    case tickerDetail(symbol:String)
    case addTickerVolume(symbol:String)
}

enum SectorNavigationEnums:Hashable{
    case sectorDetail(sector:SectorDataModel,sectorName:String)
    case tickerDetail(symbol:String)
}

enum SheetNavigationEnums:Hashable{
    case openVolumeSheet(symbol:String,volume:Int)
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

@MainActor
@Observable
class SheetNavigation{
    var sheetNav = NavigationPath()
    
    func push(route:SheetNavigationEnums){
        sheetNav.append(route)
    }
    
    func pop(){
        sheetNav.removeLast()
    }
    
    func root(){
        sheetNav = NavigationPath()
    }
}
