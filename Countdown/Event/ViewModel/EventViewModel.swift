//
//  EventViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import Combine
import Foundation
import UIKit

class EventViewModel: ObservableObject {
    
    let event: Event
    @Published var remainingText: String = ""
    @Published var isInFuture: Bool = true
    @Published var dayNumber: String = ""
    
    init(event: Event) {
        self.event = event
        updateRemainingTime()
    }
    
    private func updateRemainingTime() {
        let now = Date()
        let interval = event.date.timeIntervalSince(now)
        
        if interval > 0 {
            remainingText = formatTimeInterval(interval)
            isInFuture = true
        } else {
            remainingText = formatTimeInterval(-interval)
            isInFuture = false
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
            dayNumber = "\(days)"
            return "\(hours)h \(minutes)m \(seconds)s"

    }
}
