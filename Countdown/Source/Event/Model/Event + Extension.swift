//
//  Event + Extension.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 16/06/2026.
//

import Foundation

extension Event {
    var isInFuture: Bool {
        date >= Date()
    }

    var isUnder24Hours: Bool {
        abs(date.timeIntervalSinceNow) < 86400
    }
    
    var isUnder60Seconds: Bool {
        abs(date.timeIntervalSinceNow) < 60
    }
    
    func dayNumber(includeHours: Bool = false) -> Int {
        let interval = date.timeIntervalSince(Date())
        let absoluteInterval = abs(interval)

        if includeHours {
            return Int(absoluteInterval) / 86400
        } else {
            if isInFuture {
                return Int(ceil(absoluteInterval / 3600) * 3600) / 86400
            } else {
                return Int(floor(absoluteInterval / 3600) * 3600) / 86400
            }
        }
    }

    func hourNumber(includeSeconds: Bool = false) -> Int {
        let interval = date.timeIntervalSince(Date())
        let absoluteInterval = abs(interval)
        
        if includeSeconds {
            return (Int(absoluteInterval) % 86400) / 3600
        } else {
            if isInFuture {
                return (Int(ceil(absoluteInterval / 60) * 60) % 86400) / 3600
            } else {
                return (Int(floor(absoluteInterval / 60) * 60) % 86400) / 3600
            }
        }
    }
   
    func minuteNumber(includeSeconds: Bool = false) -> Int {
        let interval = date.timeIntervalSince(Date())
        let absoluteInterval = abs(interval)
        
        if includeSeconds {
            return (Int(absoluteInterval) % 3600) / 60
        } else {
            if isInFuture {
                return (Int(ceil(absoluteInterval / 60) * 60) % 3600) / 60
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
