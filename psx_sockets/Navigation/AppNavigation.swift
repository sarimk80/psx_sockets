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
    case indexDetail(indexName:IndexEnums,tickerDetail: SymbolDataClass)
}

enum PortfolioNavigationEnums:Hashable{
    case tickerDetail(symbol:String)
    case addTickerVolume(symbol:String)
    case tickerTransaction(symbol:String)
}

enum SectorNavigationEnums:Hashable{
    case sectorDetail(sector:SectorDataModel,sectorName:String)
    case tickerDetail(symbol:String)
}

enum SheetNavigationEnums:Hashable{
    case openVolumeSheet(symbol:String,volume:Int)
}

enum MoreNavigationEnums: Hashable{
    case searchView
    case tickerDetail(symbol:String)
    // Comment for now
    //case privacyPolicy
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

@MainActor
@Observable
class MoreNavigation{
    var moreNav = NavigationPath()
    
    func push(route:MoreNavigationEnums){
        moreNav.append(route)
    }
    
    func pop(){
        moreNav.removeLast()
    }
    
    func root(){
        moreNav = NavigationPath()
    }
}
