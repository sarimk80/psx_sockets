//
//  PsxHelper.swift
//  psx_sockets
//
//  Created by sarim khan on 07/01/2026.
//

import Foundation
import SwiftUI


func StringToIndexEnum(indexName:String) -> IndexEnums {
    switch indexName {
    case "KSE100":
        return .kse_100
    case "KMI30":
        return .kmi_30
    case "PSXDIV20":
        return .psx_div_20
    case "KSE30":
        return .kse_30
    case "MII30":
        return .mii_30
        
    default:
        return .kse_100
    }
    
}

func IndexEnumToString(indexEnum:IndexEnums) -> String {
    switch indexEnum {
    case .kse_100:
        "KSE100"
    case .kse_30:
        "KSE30"
    case .psx_div_20:
        "PSXDIV20"
    case .mii_30:
        "MII30"
    case .kmi_30:
        "KMI30"
    }
}


func calculateYScaleDomain(for items: [Annual]) -> ClosedRange<Double> {
    guard !items.isEmpty else { return 0...1 }
    
    // Extract all sales and profit values
    let allSales = items.compactMap { $0.sales }
    let allProfits = items.compactMap { $0.profitAfterTax }
    let allValues = allSales + allProfits
    
    guard let maxValue = allValues.max() else { return 0...1 }
    
    // Add 15% padding to the top, start at 0 for bar charts
    let padding = (Double(maxValue) * 0.15)
    return 0...(Double(maxValue) + padding)
}

func iconForSector(_ sector: String) -> String {
    switch sector.uppercased() {

    // MARK: Finance
    case "COMMERCIAL BANKS",
         "BANKS",
         "INVESTMENT BANKS / INVESTMENT COMPANIES / SECURITIES COMPANIES",
         "INV BANKS",
         "INSURANCE",
         "LEASING COMPANIES",
         "LEASING",
         "MODARABAS",
         "MUTUAL FUNDS",
         "CLOSE - END MUTUAL FUND",
         "EXCHANGE TRADED FUNDS",
         "ETFS":
        return "building.columns.fill"

    // MARK: Technology
    case "TECHNOLOGY & COMMUNICATION",
         "TECH & COMM":
        return "desktopcomputer"

    // MARK: Power / Energy
    case "POWER GENERATION & DISTRIBUTION",
         "POWER",
         "OIL & GAS EXPLORATION COMPANIES",
         "O&G EXPL",
         "OIL & GAS MARKETING COMPANIES",
         "O&G MKT",
         "REFINERY":
        return "bolt.fill"

    // MARK: Automobile
    case "AUTOMOBILE ASSEMBLER",
         "AUTO ASSEMBLER":
        return "car.fill"

    case "AUTOMOBILE PARTS & ACCESSORIES",
         "AUTO PARTS":
        return "steeringwheel"

    // MARK: Pharma
    case "PHARMACEUTICALS",
         "PHARMA":
        return "pills.fill"

    // MARK: Chemicals
    case "CHEMICAL",
         "CHEMICALS":
        return "testtube.2"

    // MARK: Engineering
    case "ENGINEERING":
        return "gearshape.2.fill"

    case "CABLE & ELECTRICAL GOODS",
         "CABLE & ELEC":
        return "cable.connector"

    // MARK: Cement / Construction
    case "CEMENT":
        return "building.2.fill"

    case "GLASS & CERAMICS",
         "GLASS & CERAM":
        return "square.stack.3d.up.fill"

    // MARK: Property
    case "PROPERTY",
         "REAL ESTATE":
        return "house.fill"

    // MARK: Food
    case "FOOD & PERSONAL CARE PRODUCTS",
         "FOOD & CARE":
        return "cart.fill"

    case "SUGAR":
        return "cube.fill"

    case "TOBACCO":
        return "smoke.fill"

    case "VANASPATI & ALLIED INDUSTRIES",
         "VANASPATI":
        return "fork.knife"

    // MARK: Textile
    case "TEXTILE SPINNING",
         "TEXTILE SPIN",
         "TEXTILE WEAVING",
         "TEXTILE WEAV",
         "TEXTILE COMPOSITE",
         "TEXTILE COMP",
         "WOOLLEN",
         "APPAREL":
        return "tshirt.fill"

    case "LEATHER & TANNERIES",
         "LEATHER":
        return "shoeprints.fill"

    // MARK: Agriculture
    case "FERTILIZER":
        return "leaf.fill"

    // MARK: Packaging
    case "PAPER & BOARD",
         "PAPER & PACK":
        return "shippingbox.fill"

    // MARK: Transport
    case "TRANSPORT":
        return "truck.box.fill"

    // MARK: Miscellaneous
    case "JUTE":
        return "basket.fill"

    case "SYNTHETIC & RAYON":
        return "circle.grid.cross.fill"

    case "MISCELLANEOUS",
         "MISC":
        return "cube.box.fill"

    // MARK: Futures
    case "FUTURE CONTRACTS":
        return "chart.line.uptrend.xyaxis"

    default:
        return "building.2"
    }
}

struct SpringButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}

func marketStatusString(market:String) -> String {
    switch market {
    case "Pre-Open Session":
        "Pre-market"
    case "Normal Trading Session":
        "Open"
    case "Post-Close Session":
        "Closed"
    case "Order Matching":
        "Order Matching"
    default:
        "Open"
    }
}


//PRE    Pre-market
//OPN    Open
//SUS    Suspended
//CLS    Closed

func visibleDomainLenght(chartTimeFrame:ChartTimeFrame) -> TimeInterval {
    let minute: TimeInterval = 60
    let hour = 60 * minute
    let day = 24 * hour
    
    switch chartTimeFrame {
    case .M1:
        return hour              // 60 candles (1h)
    case .M5:
        return 5 * hour          // 5h
    case .M15:
        return 15 * hour         // 15h
    case .H1:
        return day               // 1 day
    case .H4:
        return 4 * day           // 4 days
    case .D1:
        return 60 * day          // 60 days
    }
}
