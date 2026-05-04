//
//  EventModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import Foundation

struct Event: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let date: Date
    var imageName: URL
    var categoryID: UUID?
}
