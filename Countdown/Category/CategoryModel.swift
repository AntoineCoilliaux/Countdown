//
//  CategoryModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 25/02/2026.
//

import Foundation

struct Category: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
}
