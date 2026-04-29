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
    
    var dayNumber: String {
        let interval = abs(date.timeIntervalSince(Date()))
        let days = Int(ceil(interval / 60) * 60) / 86400
        return "\(days)"
    }
    
    var remainingText: String {
        let interval = abs(date.timeIntervalSince(Date()))
        let roundedInterval = ceil(interval / 60) * 60
        let hours = (Int(roundedInterval) % 86400) / 3600
        let minutes = (Int(roundedInterval) % 3600) / 60
        
        return "\(hours)h \(minutes)m"
    }
}
