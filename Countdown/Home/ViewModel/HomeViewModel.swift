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
    private var updateTimer: Timer?
    
    init() {
        self.events = loadEvents()
        sortEvents()
        startSortTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    private func startSortTimer() {
        // Vérifie toutes les secondes si un tri est nécessaire
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sortEvents()
            self?.objectWillChange.send()

        }
    }
    
    func addEvent(_ event: Event) {
        events.append(event)
        sortEvents()
        saveEvents()
    }
    
    func sortEvents() {
        let now = Date()
        
        let sortedEvents = events.sorted { a, b in
            let aIsFuture = a.date >= now
            let bIsFuture = b.date >= now

            if aIsFuture != bIsFuture {
                return aIsFuture
            }

            return aIsFuture ? a.date < b.date : a.date > b.date
        }
        
        // Ne met à jour que si l'ordre a changé
        if sortedEvents.map({ $0.id }) != events.map({ $0.id }) {
            events = sortedEvents
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
    
    func updateEvent(_ updatedEvent: Event) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events[index] = updatedEvent
            saveEvents()
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
