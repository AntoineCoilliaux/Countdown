//
//  CountdownApp.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI
import TipKit

@main
struct CountdownApp: App {
    @StateObject private var eventStore: EventStore
    @StateObject private var categoryManager: CategoryManager
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        let store = EventStore()
        _eventStore = StateObject(wrappedValue: store)
        _categoryManager = StateObject(wrappedValue: CategoryManager(eventStore: store))
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
            .displayFrequency(.immediate)
        ])
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(eventStore)
                .environmentObject(categoryManager)
                .environmentObject(notificationManager)
        }
    }
}
