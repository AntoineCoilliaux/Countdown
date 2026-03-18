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
    @Published private(set) var filteredEvents: [Event] = []

    private let eventStore: EventStore
    private let categoryManager: CategoryManager
    private var cancellables = Set<AnyCancellable>()

    init(eventStore: EventStore, categoryManager: CategoryManager) {
        self.eventStore = eventStore
        self.categoryManager = categoryManager

        // Combine events and selected category to produce filteredEvents
        Publishers.CombineLatest(eventStore.$events, categoryManager.$selectedCategoryId)
            .map { events, selectedId in
                guard let id = selectedId else { return events }
                return events.filter { $0.categoryID == id }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$filteredEvents)
    }

    // Expose selected category for convenience
    var selectedCategoryId: UUID? { categoryManager.selectedCategoryId }

    // MARK: - CRUD forwarding
    func addEvent(_ event: Event) {
        eventStore.add(event)
    }

    func updateEvent(_ event: Event) {
        eventStore.update(event)
    }

    func deleteEvents(withIds ids: [UUID]) {
        eventStore.delete(withIds: ids)
    }
}
