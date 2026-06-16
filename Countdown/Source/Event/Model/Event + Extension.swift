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

    var dayNumber: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDay = calendar.startOfDay(for: date)
        return abs(calendar.dateComponents([.day], from: today, to: eventDay).day ?? 0)
    }

    var isUnder24Hours: Bool {
        abs(date.timeIntervalSinceNow) < 86400
    }

    var hourNumber: Int {
        let interval = abs(date.timeIntervalSince(Date()))
        return (Int(ceil(interval / 60) * 60) % 86400) / 3600
    }

    var minuteNumber: Int {
        let interval = abs(date.timeIntervalSince(Date()))
        return (Int(ceil(interval / 60) * 60) % 3600) / 60
    }

    var secondNumber: Int {
        let interval = abs(date.timeIntervalSince(Date()))
        return Int(interval) % 60
    }

    var progressFraction: CGFloat {
        let total: TimeInterval = 50 * 86400
        let remaining = max(date.timeIntervalSince(Date()), 0)
        let elapsed = total - min(remaining, total)
        return CGFloat(elapsed / total)
    }

    var formattedFullDate: String {
        date.formatted(date: .complete, time: .shortened)
    }

    var repeatRuleText: String {
        switch repeatRule {
        case .never: return "Never"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .none: return ""
        }
    }
}
