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
    var createdAt: Date?
    var imageName: URL
    var categoryID: UUID?
    var emoji: String?
    var displayMode: EventDisplayMode? = .photo
    var reminders: [ReminderOption] = []
}

enum EventDisplayMode: String, Codable {
    case photo, emoji
}

