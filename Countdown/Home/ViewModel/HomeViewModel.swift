//
//  HomeViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//
import Combine
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    func addEvent(_ event: Event) {
        events.append(event)
        sortEvents()
        saveEvents()
    }
    
    func sortEvents() {
        let now = Date()

        events.sort { a, b in
            let aIsFuture = a.date >= now
            let bIsFuture = b.date >= now

            // 1️⃣ Futur avant passé
            if aIsFuture != bIsFuture {
                return aIsFuture
            }

            // 2️⃣ Les deux sont futurs → plus proche en premier
            if aIsFuture {
                return a.date < b.date
            }

            // 3️⃣ Les deux sont passés → plus récent en premier
            return a.date > b.date
        }
    }

    
    private func saveEvents() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: K.userDefaultsKeys.events)
        } catch {
            print("Failed to encode events:", error)
        }
    }
    
    func loadEvents() -> [Event] {
        guard let data = UserDefaults.standard.data(forKey: K.userDefaultsKeys.events) else { return [] }
        do {
            return try JSONDecoder().decode([Event].self, from: data)
        } catch {
            print("Failed to decode events:", error)
            return []
        }
    }
    
    func deleteEvent(_ indexSet: IndexSet) {
        events.remove(atOffsets: indexSet)
        saveEvents()
    }
}
