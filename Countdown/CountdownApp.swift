//
//  CountdownApp.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var eventStore = EventStore()
    @StateObject private var categoryManager: CategoryManager
    @StateObject private var flagsVM = FlagsPickerViewModel()
    
    init() {
        let store = EventStore()
        _eventStore = StateObject(wrappedValue: store)
        _categoryManager = StateObject(wrappedValue: CategoryManager(eventStore: store))
    }

    var body: some Scene {
        WindowGroup {
            HomeViewWrapper()
                .environmentObject(eventStore)
                .environmentObject(categoryManager)
                .environmentObject(flagsVM)
        }
    }
}
