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
        sortEvents()
        startSortTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    private func startSortTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sortEvents()
            self?.objectWillChange.send()

        }
    }
    
    //MARK - Events
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
        
        if sortedEvents.map({ $0.id }) != events.map({ $0.id }) {
            events = sortedEvents
        }
    }
    private func saveEvents() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: K.HomeViewModel.userDefaultsKeyEvents)
            UserDefaults.standard.synchronize()
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
        guard let data = UserDefaults.standard.data(forKey: K.HomeViewModel.userDefaultsKeyEvents) else {
            return []
        }
        do {
            let events = try JSONDecoder().decode([Event].self, from: data)
            
            for event in events {
               
                if event.imageName.isFileURL {
                    let _ = FileManager.default.fileExists(atPath: event.imageName.path)
                }
            }
            return events
        } catch {
            return []
        }
    }
    
    func deleteEvent(_ indexSet: IndexSet) {
        for index in indexSet {
            let event = events[index]
            if event.imageName.isFileURL {
                try? FileManager.default.removeItem(at: event.imageName)
            }
        }
        events.remove(atOffsets: indexSet)
        saveEvents()
    }
    
    //MARK: - Categories
    
    func deleteCategory(id: UUID, deleteEvents: Bool, categoryManager: CategoryManager) {
        if deleteEvents {
            events.removeAll { $0.categoryID == id }
        } else {
            for i in 0..<events.count {
                if events[i].categoryID == id {
                    events[i] = Event(
                        id: events[i].id,
                        name: events[i].name,
                        date: events[i].date,
                        imageName: events[i].imageName,
                        categoryID: nil
                    )
                }
            }
        }
        
        saveEvents()
        categoryManager.deleteCategory(id: id)
    }
     
     func deleteEvents(withIds ids: [UUID]) {
         for id in ids {
             if let index = events.firstIndex(where: { $0.id == id }) {
                 let event = events[index]
                 if event.imageName.isFileURL {
                     try? FileManager.default.removeItem(at: event.imageName)
                 }
             }
         }
         events.removeAll { ids.contains($0.id) }
         saveEvents()
     }
}
