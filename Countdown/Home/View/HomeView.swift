//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    @EnvironmentObject private var categoryManager: CategoryManager
    
    @State private var showingAddEvent = false
    @State private var showingManageCategories = false
    @State private var selectedCategoryId: UUID?
    @State private var categoryIndexPendingDeletion: IndexSet?
    @State private var showDeleteCategoryAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if !vm.events.isEmpty {
                    eventList
                } else {
                    Spacer()
                    Text(K.HomeView.noEventsYet)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    categoryListView
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: K.HomeView.plusButon)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                vm.events = vm.loadEvents()
                vm.sortEvents()
            }
            .sheet(isPresented: $showingAddEvent) {
                EditorView { newEvent in
                    vm.addEvent(newEvent)
                }
            }
            .sheet(isPresented: $showingManageCategories) {
                ManageCategoriesView(
                    categoryManager: categoryManager,
                    onDelete: { id, deleteEvents in
                        vm.deleteCategory(
                            id: id,
                            deleteEvents: deleteEvents,
                            categoryManager: categoryManager
                        )
                    }
                )
            }
        }
    }
    
    // MARK: - Sections
    
    private var categoryListView: some View {
        Menu {
            Button(action: { selectedCategoryId = nil }) {
                Label("All", systemImage: selectedCategoryId == nil ? "checkmark" : "")
            }
            
            Divider()
            
            if !categoryManager.categories.isEmpty {
                ForEach(categoryManager.categories) { category in
                    Button(action: { selectedCategoryId = category.id }) {
                        HStack {
                            Circle().fill(.yellow).frame(width: 10, height: 10)
                            Text(category.name)
                            if selectedCategoryId == category.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // ✅ Bouton "Manage"
            Button(action: { showingManageCategories = true }) {
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
            ForEach(filteredEvents) { event in
                NavigationLink {
                    EditorView(event: event) { updatedEvent in
                        vm.updateEvent(updatedEvent)
                    }
                } label: {
                    EventView(viewModel: EventViewModel(event: event))
                }
            }
            .onDelete { indexSet in
                handleDeleteEvents(indexSet)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currentCategoryName: String {
        if let id = selectedCategoryId,
           let cat = categoryManager.categories.first(where: { $0.id == id }) {
            return cat.name
        }
        return "All"
    }
    
    private var filteredEvents: [Event] {
        guard let selectedCategoryId else { return vm.events }
        return vm.events.filter { $0.categoryID == selectedCategoryId }
    }
    
    private func handleDeleteCategory(deleteEvents: Bool) {
        guard let indexSet = categoryIndexPendingDeletion else { return }
        
        for index in indexSet {
            let category = categoryManager.categories[index]
            vm.deleteCategory(
                id: category.id,
                deleteEvents: deleteEvents,
                categoryManager: categoryManager
            )
        }
        
        categoryIndexPendingDeletion = nil
    }
    
    private func handleDeleteEvents(_ indexSet: IndexSet) {
        let eventsToDelete = indexSet.map { filteredEvents[$0].id }
        vm.deleteEvents(withIds: eventsToDelete)
    }
}

#Preview {
    HomeView()
}

