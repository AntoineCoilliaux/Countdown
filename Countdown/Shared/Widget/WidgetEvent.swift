//
//  WidgetEvent.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 22/04/2026.
//

import Foundation

struct WidgetEvent: Codable {
    let id: UUID
    let name: String
    let date: Date
    let categoryName: String?
    let categoryColor: String?
    let emoji: String?
    let imageName: URL?
    let imageData: Data?
    var displayMode: EventDisplayMode?
    
    func isInFuture(relativeTo referenceDate: Date) -> Bool {
        date > referenceDate
    }
}
