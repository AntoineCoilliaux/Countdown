//
//  CountdownApp.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI

@main
struct CountdownApp: App {
    
    @StateObject private var categoryManager = CategoryManager()  // ✅ Singleton global

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(categoryManager)
        }
    }
}
