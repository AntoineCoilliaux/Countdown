//
//  Event + Extension.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 16/06/2026.
//

import Foundation

extension Event {
    var isInFuture: Bool {
        date > Date()
    }

    var isUnder24Hours: Bool {
        abs(date.timeIntervalSinceNow) < 86340
    }
    
    var itsTime: Bool {
        abs(date.timeIntervalSinceNow) < 1
    }
    
    func dayNumber(includeHours: Bool = false) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        if includeHours {
            let components = calendar.dateComponents([.day], from: now, to: date)
            return abs(components.day ?? 0)
        } else {
          
            let startOfNow = calendar.startOfDay(for: now)
            let startOfEvent = calendar.startOfDay(for: date)
            
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfEvent)
            return abs(components.day ?? 0)
        }
    }

    func hourNumber() -> Int {
        let interval = date.timeIntervalSince(Date())
        let totalMinutes = Int(ceil(abs(interval) / 60))
        return (totalMinutes / 60) % 24
    }

    func minuteNumber(includeSeconds: Bool = false) -> Int {
        let interval = date.timeIntervalSince(Date())
        let absoluteInterval = abs(interval)
        
        if includeSeconds {
            return (Int(absoluteInterval) % 3600) / 60
        } else {
            if isInFuture {
                let totalMinutes = Int(ceil(absoluteInterval / 60))
                return totalMinutes % 60
            } else {
                return (Int(floor(absoluteInterval / 60) * 60) % 3600) / 60
            }
        }

    }

    var secondNumber: Int {
        let interval = abs(date.timeIntervalSince(Date()))
        return Int(interval) % 60
    }

    var progressFraction: CGFloat {
        let creation = createdAt ?? date.addingTimeInterval(-50 * 86400)
        let total = max(date.timeIntervalSince(creation), 1)
        let elapsed = max(Date().timeIntervalSince(creation), 0)
        return CGFloat(min(elapsed / total, 1))
    }
    
    var formattedFullDate: String {
        date.formatted(date: .complete, time: .shortened)
    }
}
