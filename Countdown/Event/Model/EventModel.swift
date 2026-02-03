//
//  EventModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import Foundation

struct Event: Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let imageName: String?
}
