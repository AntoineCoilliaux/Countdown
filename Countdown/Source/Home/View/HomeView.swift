//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var categoryManager: CategoryManager

    @State private var showingAddEvent = false
    @State private var showingManageCategories = false

    var body: some View {
        NavigationStack {
            Group {
                if filteredEvents.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    categoryMenuView
                }
                ToolbarItem(placement: .topBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                EditorView { newEvent in
                    eventStore.add(newEvent)
                }
            }
            .sheet(isPresented: $showingManageCategories) {
                ManageCategoriesView()
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        ContentUnavailableView(
            K.HomeView.noEventsYet,
            systemImage: "calendar.badge.clock"
        )
    }

    private var addButton: some View {
        Button {
            showingAddEvent = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }

    private var categoryMenuView: some View {
        Menu {
            Button {
                categoryManager.selectedCategoryId = nil
            } label: {
                Label("All", systemImage: categoryManager.selectedCategoryId == nil ? "checkmark" : "")
            }

            Divider()

            ForEach(categoryManager.categories) { category in
                Button {
                    categoryManager.selectedCategoryId = category.id
                } label: {
                    Label(
                        category.name,
                        systemImage: categoryManager.selectedCategoryId == category.id ? "checkmark" : ""
                    )
                }
            }

            Divider()
            if !categoryManager.categories.isEmpty {
                Button {
                    showingManageCategories = true
                } label: {
                    Label("Manage Categories", systemImage: "pencil")
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(currentCategoryName)
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var eventList: some View {
        List {
            ForEach(filteredEvents) { event in
                NavigationLink {
                    EditorView(event: event) { updatedEvent in
                        eventStore.update(updatedEvent)
                    }
                } label: {
                    EventView(event: event)
                }
            }
            .onDelete { indexSet in
                let ids = indexSet.map { filteredEvents[$0].id }
                eventStore.delete(withIds: ids)
            }
        }
    }

    // MARK: - Helpers

    private var filteredEvents: [Event] {
        guard let id = categoryManager.selectedCategoryId else {
            return eventStore.events
        }
        return eventStore.events.filter { $0.categoryID == id }
    }

    private var currentCategoryName: String {
        guard let id = categoryManager.selectedCategoryId,
              let category = categoryManager.categories.first(where: { $0.id == id })
        else { return "All" }
        return category.name
    }
}

// MARK: - Preview

#Preview {
    let eventStore = EventStore()
    let categoryManager = CategoryManager(eventStore: eventStore)
    HomeView()
        .environmentObject(eventStore)
        .environmentObject(categoryManager)
}
