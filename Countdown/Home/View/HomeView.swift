//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

// MARK: - Wrapper

struct HomeViewWrapper: View {
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var categoryManager: CategoryManager

    var body: some View {
        HomeView(vm: HomeViewModel(eventStore: eventStore, categoryManager: categoryManager))
    }
}

// MARK: - HomeView

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    @EnvironmentObject private var categoryManager: CategoryManager

    @State private var showingAddEvent = false
    @State private var showingManageCategories = false

    init(vm: HomeViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.filteredEvents.isEmpty {
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
                    vm.addEvent(newEvent)
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
            Image(systemName: K.HomeView.plusButon)
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

            Button {
                showingManageCategories = true
            } label: {
                Label("Manage Categories", systemImage: "pencil")
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
            ForEach(vm.filteredEvents) { event in
                NavigationLink {
                    EditorView(event: event) { updatedEvent in
                        vm.updateEvent(updatedEvent)
                    }
                } label: {
                    EventView(viewModel: EventViewModel(event: event))
                }
            }
            .onDelete { indexSet in
                let ids = indexSet.map { vm.filteredEvents[$0].id }
                vm.deleteEvents(withIds: ids)
            }
        }
    }

    // MARK: - Helpers

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
    HomeView(vm: HomeViewModel(eventStore: eventStore, categoryManager: categoryManager))
        .environmentObject(categoryManager)
        .environmentObject(eventStore)
}
