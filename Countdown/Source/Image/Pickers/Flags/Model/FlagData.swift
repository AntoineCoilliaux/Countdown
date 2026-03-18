//
//  FlagData.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 17/03/2026.
//

import Foundation

struct FlagData: Codable, Identifiable {
    var id: String { flags.png }
    let flags: Flags
}

struct Flags: Codable {
    let png: String
}
