//
//  MetalListModel.swift
//  psx_sockets
//
//  Created by sarim khan on 21/08/2026.
//

import Foundation
import SwiftUI

struct MetalListModel: Codable {
    let gold: String
    let silver: String
    let platinum: String
    let palladium: String
    let wtiCrudeOil: String
    let brentCrudeOil: String
    let naturalGas: String
    let gasoline: String
    let heatingOil: String
    let copper: String
    let corn: String
    let wheat: String
    let soybeans: String
    let oats: String
    let roughRice: String
    let coffee: String
    let sugar: String
    let cocoa: String
    let cotton: String
    let lumber: String
    let orangeJuice: String
    let liveCattle: String
    let feederCattle: String
    let leanHogs: String

    enum CodingKeys: String, CodingKey {
        case gold = "Gold"
        case silver = "Silver"
        case platinum = "Platinum"
        case palladium = "Palladium"
        case wtiCrudeOil = "WTI Crude Oil"
        case brentCrudeOil = "Brent Crude Oil"
        case naturalGas = "Natural Gas"
        case gasoline = "Gasoline"
        case heatingOil = "Heating Oil"
        case copper = "Copper"
        case corn = "Corn"
        case wheat = "Wheat"
        case soybeans = "Soybeans"
        case oats = "Oats"
        case roughRice = "Rough Rice"
        case coffee = "Coffee"
        case sugar = "Sugar"
        case cocoa = "Cocoa"
        case cotton = "Cotton"
        case lumber = "Lumber"
        case orangeJuice = "Orange Juice"
        case liveCattle = "Live Cattle"
        case feederCattle = "Feeder Cattle"
        case leanHogs = "Lean Hogs"
    }
    
}

struct Commodity:Codable,Identifiable {

    let name:String
    let symbol:String
    
    
    var id:String {name}
    
    var icon: String {
            switch name {
            // Metals
            case "Gold": return "circlebadge.fill"
            case "Silver": return "circle.hexagongrid.fill"
            case "Platinum": return "diamond.fill"
            case "Palladium": return "hexagon.fill"
            case "Copper": return "circle.grid.cross.fill"

            // Energy
            case "Brent Crude Oil", "WTI Crude Oil": return "drop.fill"
            case "Natural Gas": return "flame.fill"
            case "Gasoline": return "fuelpump.fill"
            case "Heating Oil": return "thermometer.medium"

            // Agriculture
            case "Corn": return "leaf.fill"
            case "Wheat": return "wind"
            case "Soybeans": return "leaf.circle.fill"
            case "Oats": return "circle.grid.2x2.fill"
            case "Rough Rice": return "aqi.medium"
            case "Coffee": return "cup.and.saucer.fill"
            case "Sugar": return "aqi.medium"
            case "Cocoa": return "circle.fill"
            case "Cotton": return "cloud.fill"
            case "Lumber": return "tree.fill"
            case "Orange Juice": return "sun.max.fill"

            // Livestock
            case "Live Cattle", "Feeder Cattle": return "pawprint.fill"
            case "Lean Hogs": return "pawprint.circle.fill"

            default: return "questionmark.circle"
            }
        }
    
    var iconColor: Color {
            switch name {
            // Metals
            case "Gold": return .yellow
            case "Silver": return .gray
            case "Platinum": return .blue
            case "Palladium": return .red
            case "Copper": return .orange

            // Energy
            case "Brent Crude Oil": return .teal
            case "WTI Crude Oil" : return .purple
            case "Natural Gas": return .red
            case "Gasoline": return .cyan
            case "Heating Oil": return .indigo

            // Agriculture
            case "Corn": return .indigo
            case "Wheat": return .pink
            case "Soybeans": return .purple
            case "Oats": return .teal
            case "Rough Rice": return .mint
            case "Coffee": return .brown
            case "Sugar": return .blue
            case "Cocoa": return .yellow
            case "Cotton": return .cyan
            case "Lumber": return .teal
            case "Orange Juice": return .orange

            // Livestock
            case "Live Cattle": return .gray
            case "Feeder Cattle" : return .yellow
            case "Lean Hogs": return .mint

            default: return .red
            }
        }
    
}

extension Commodity {
    static let mock = [
        Commodity(name: "Gold", symbol: "Gold"),
        Commodity(name: "Silver", symbol: "Silver"),
        Commodity(name: "Oil", symbol: "Oil"),
        Commodity(name: "Orange Juice", symbol: "Orange Juice"),
        Commodity(name: "Coffee", symbol: "Coffee"),
    ]
}
