//
//  PsxHelper.swift
//  psx_sockets
//
//  Created by sarim khan on 07/01/2026.
//

import Foundation


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
