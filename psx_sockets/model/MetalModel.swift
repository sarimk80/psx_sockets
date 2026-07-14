//
//  MetalModel.swift
//  psx_sockets
//
//  Created by sarim khan on 10/07/2026.
//

import Foundation


struct MetalModel: Codable {
    var day, maxPrice: String

    enum CodingKeys: String, CodingKey {
        case day
        case maxPrice = "max_price"
    }
}
