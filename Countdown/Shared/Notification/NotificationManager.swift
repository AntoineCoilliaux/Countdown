//
//  NotificationManager.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 23/06/2026.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {

    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    init() {
        Task { await refreshAuthorizationStatus() }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }


    @discardableResult
    func requestPermissionIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                await refreshAuthorizationStatus()
                return granted
            } catch {
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    var isDenied: Bool { authorizationStatus == .denied }

    // MARK: - Schedule


    func scheduleReminders(for event: Event) async {
        guard !event.reminders.isEmpty else { return }
        let authorized = await requestPermissionIfNeeded()
        guard authorized else { return }

        for reminder in event.reminders {
            guard let fireDate = reminder.fireDate(for: event.date) else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = event.name
            content.body = notificationBody(reminder: reminder, eventDate: event.date)
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let identifier = reminder.notificationIdentifier(for: event.id)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                print("[NotificationManager] Failed to schedule \(identifier): \(error)")
            }
        }
    }

    // MARK: - Cancel
    
    func cancelReminders(for event: Event) {
        let identifiers = event.reminders.map { $0.notificationIdentifier(for: event.id) }
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAllReminders(for eventId: UUID, reminders: [ReminderOption]) {
        let identifiers = reminders.map { $0.notificationIdentifier(for: eventId) }
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Reschedule

    func rescheduleReminders(oldEvent: Event, newEvent: Event) async {
        cancelReminders(for: oldEvent)
        await scheduleReminders(for: newEvent)
    }

    // MARK: - Helpers

    private var notificationBodyVariants: [ReminderOption: [String]] = [
        .oneHour: [
            "Your event starts in 1 hour. Get ready!",
            "1 hour to go. Almost there!",
            "Tick tock — your event is in 1 hour.",
            "1 hour left. Time to get moving.",
            "Your event is just around the corner — 1 hour away.",
            "Heads up! Your event starts in 1 hour.",
            "60 minutes and counting.",
            "1 hour until it happens.",
            "Don't forget — your event is in 1 hour.",
            "Final hour! Your event is coming up."
        ],
        .oneDay: [
            "Your event is tomorrow. Are you ready?",
            "Tomorrow's the day!",
            "Just one day to go.",
            "Your event is happening tomorrow.",
            "24 hours away — your event is almost here.",
            "One more sleep before it happens!",
            "Your event is tomorrow. Don't miss it.",
            "The countdown is almost over — see you tomorrow.",
            "Tomorrow it happens."
        ],
        .oneWeek: [
            "Your event is in 1 week. Mark your calendar!",
            "7 days to go!",
            "One week until the big day.",
            "Your event is coming up in a week.",
            "A week from now, it'll be happening.",
            "7 days and counting.",
            "One week away — start getting excited.",
            "Your event is just a week out.",
            "The countdown begins — 1 week to go.",
            "One week left. Make it count."
        ]
    ]

    private func notificationBody(reminder: ReminderOption, eventDate: Date) -> String {
        switch reminder {
        case .custom:
            let formatted = eventDate.formatted(date: .abbreviated, time: .shortened)
            return "Your event is on \(formatted)."
        default:
            let variants = notificationBodyVariants[reminder] ?? []
            return variants.randomElement() ?? ""
        }
    }
}
