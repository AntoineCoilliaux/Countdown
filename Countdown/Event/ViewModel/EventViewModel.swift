//
//  EventViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import Combine
import Foundation

class EventViewModel: ObservableObject {
    @Published var title : String
    @Published var date : Date
    @Published var remainingText: String
    
    let event: Event

    init(title: String, date: Date, remainingText: String, event: Event) {
        self.title = title
        self.date = date
        self.remainingText = remainingText
        self.event = event
    }

    var remainingInterval: TimeInterval {
        event.date.timeIntervalSinceNow
    }

    var isInFuture: Bool {
        remainingInterval >= 0
    }

    var remainingTextInDays: String {
        let absInterval = abs(remainingInterval)
        let days = Int(absInterval) / 86400
        let hours = (Int(absInterval) % 86400) / 3600
        let minutes = (Int(absInterval) % 3600) / 60

        if isInFuture {
            return "Dans \(hours)h \(minutes)m"
        } else {
            return "Il y a \(hours)h \(minutes)m"
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: event.date)
    }
}

