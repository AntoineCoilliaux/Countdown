//
//  EventStore.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 16/03/2026.
//
import Combine
import Foundation
import SwiftUI

final class EventStore: ObservableObject {
    @Published private(set) var events: [Event] = []

    private var sortTimer: Timer?

    init() {
        self.events = load()
        sortEvents()
        startSortTimer()
    }

    deinit {
        sortTimer?.invalidate()
    }

    // MARK: - Public API

    func add(_ event: Event) {
        events.append(event)
        sortEvents()
        save()
    }

    func update(_ event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            events[idx] = event
            sortEvents()
            save()
        }
    }

    func delete(withIds ids: [UUID]) {
        for id in ids {
            if let index = events.firstIndex(where: { $0.id == id }) {
                let event = events[index]
                if event.imageName.isFileURL {
                    try? FileManager.default.removeItem(at: event.imageName)
                }
            }
        }
        events.removeAll { ids.contains($0.id) }
        save()
    }

    func deleteEvents(inCategory id: UUID) {
        for event in events where event.categoryID == id {
            if event.imageName.isFileURL {
                try? FileManager.default.removeItem(at: event.imageName)
            }
        }
        events.removeAll { $0.categoryID == id }
        save()
    }

    func moveEventsFromCategoryToAll(_ id: UUID) {
        for i in events.indices where events[i].categoryID == id {
            events[i].categoryID = nil
        }
        save()
    }


    // MARK: - Sorting

    private func sortEvents() {
        let now = Date()
        let sorted = events.sorted { a, b in
            let aIsFuture = a.date >= now
            let bIsFuture = b.date >= now
            if aIsFuture != bIsFuture { return aIsFuture }
            return aIsFuture ? a.date < b.date : a.date > b.date
        }
        if sorted.map({ $0.id }) != events.map({ $0.id }) {
            events = sorted
        }
    }

    private func startSortTimer() {
        sortTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sortEvents()
        }
    }

    // MARK: - Persistence

    private func load() -> [Event] {
        guard let data = UserDefaults.standard.data(forKey: K.HomeViewModel.userDefaultsKeyEvents) else {
            return []
        }
        return (try? JSONDecoder().decode([Event].self, from: data)) ?? []
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: K.HomeViewModel.userDefaultsKeyEvents)
        }
    }
}
