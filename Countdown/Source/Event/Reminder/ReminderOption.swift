//
//  ReminderOption.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/06/2026.
//

import Foundation

enum ReminderOption: Codable, Equatable, Hashable, Identifiable {
    case oneHour
    case oneDay
    case oneWeek
    case custom(Date)

    var id: String {
        switch self {
        case .oneHour: return "oneHour"
        case .oneDay: return "oneDay"
        case .oneWeek: return "oneWeek"
        case .custom(let date): return "custom-\(date.timeIntervalSince1970)"
        }
    }

    /// Short label shown in the editor row and in pickers,
    /// e.g. "1 hour before", "Jun 22, 9:00 AM".
    var label: String {
        switch self {
        case .oneHour: return "1 hour before"
        case .oneDay: return "1 day before"
        case .oneWeek: return "1 week before"
        case .custom(let date): return date.formatted(date: .abbreviated, time: .shortened)
        }
    }

    /// The actual moment the notification should fire, given the event's date.
    /// Returns nil if that moment is already in the past (so it won't be scheduled).
    func fireDate(for eventDate: Date) -> Date? {
        let candidate: Date
        switch self {
        case .oneHour:
            candidate = Calendar.current.date(byAdding: .hour, value: -1, to: eventDate) ?? eventDate
        case .oneDay:
            candidate = Calendar.current.date(byAdding: .day, value: -1, to: eventDate) ?? eventDate
        case .oneWeek:
            candidate = Calendar.current.date(byAdding: .day, value: -7, to: eventDate) ?? eventDate
        case .custom(let date):
            candidate = date
        }
        return candidate > Date() ? candidate : nil
    }

    /// Stable identifier used as the notification request identifier,
    /// scoped to a specific event so reminders can be cancelled per-event.
    func notificationIdentifier(for eventId: UUID) -> String {
        "event-\(eventId.uuidString)-reminder-\(id)"
    }
}

/// Presets offered as quick-add buttons; "Custom" is handled separately
/// in the UI since it needs a date/time picker rather than a single tap.
enum ReminderPreset: CaseIterable {
    case oneHour, oneDay, oneWeek

    var option: ReminderOption {
        switch self {
        case .oneHour: return .oneHour
        case .oneDay: return .oneDay
        case .oneWeek: return .oneWeek
        }
    }

    var label: String {
        switch self {
        case .oneHour: return "1 hour before"
        case .oneDay: return "1 day before"
        case .oneWeek: return "1 week before"
        }
    }
}
