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
    switch sector {

    // MARK: - Finance
    case "BANKS",
         "INV BANKS",
         "INSURANCE",
         "LEASING",
         "MUTUAL FUND",
         "ETFS",
         "MODARABAS":
        return "building.columns.fill"

    // MARK: - Energy / Oil / Power
    case "POWER",
         "O&G EXPL",
         "O&G MKT",
         "REFINERY":
        return "bolt.fill"

    // MARK: - Technology
    case "TECH & COMM":
        return "cpu.fill"

    // MARK: - Automotive / Transport
    case "AUTO PARTS",
         "AUTO ASSEMBLER",
         "TRANSPORT":
        return "car.fill"

    // MARK: - Pharma / Medical
    case "PHARMA":
        return "pills.fill"

    // MARK: - Chemicals / Industrial
    case
        "CABLE & ELEC",
         "ENGINEERING",
         "SYNTHETIC":
        return "gearshape.fill"
        
    case "CHEMICAL":
        return "testtube.2"

    // MARK: - Construction / Materials
    case "CEMENT",
         "GLASS & CERAM":
        return "hammer.fill"

    // MARK: - Real Estate
    case "PROPERTY",
         "REAL ESTATE":
        return "house.fill"

    // MARK: - Consumer / Food
    case "FOOD & CARE",
         "VANASPATI",
         "SUGAR",
         "TOBACCO":
        return "cart.fill"

    // MARK: - Textile / Leather
    case "TEXTILE SPIN",
         "TEXTILE WEAV",
         "TEXTILE COMP",
         "WOOLLEN",
         "LEATHER":
        return "tshirt.fill"

    // MARK: - Packaging / Paper
    case "PAPER & PACK":
        return "shippingbox.fill"

    // MARK: - Agriculture / Fertilizer
    case "FERTILIZER":
        return "leaf.fill"

    // MARK: - Misc / Manufacturing
    case "MISC",
         "JUTE":
        return "cube.box.fill"

    default:
        // ⭐ VERY IMPORTANT fallback
        return "circle"
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
    case "PRE":
        "Pre-market"
    case "OPN":
        "Open"
    case "SUS":
        "Suspended"
    case "CLS":
        "Closed"
    default:
        "Open"
    }
}


//PRE    Pre-market
//OPN    Open
//SUS    Suspended
//CLS    Closed
