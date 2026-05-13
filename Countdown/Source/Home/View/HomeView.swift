//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI
import TipKit
import WidgetKit

struct HomeView: View {
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var categoryManager: CategoryManager
    @StateObject private var network = NetworkMonitor()

    @State private var showingManageCategories = false
    
    private let widgetTip = WidgetTip()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: K.Colors.appBackground)
                    .ignoresSafeArea()
                
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
                    NavigationLink {
                        EditorView { newEvent in
                            eventStore.add(newEvent)
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .sheet(isPresented: $showingManageCategories) {
                ManageCategoriesView()
            }
            
            .onChange(of: eventStore.events) { oldEvents, newEvents in
                if oldEvents.isEmpty && newEvents.count == 1 {
                    Task {
                        await WidgetTip.firstEventCreated.donate()

                    }
                }
                syncWidgetEvents()
            }
            .onChange(of: categoryManager.categories) { _, _ in
                syncWidgetEvents()
            }
            
            .onChange(of: network.isConnected) { _, isConnected in
                guard isConnected else { return }
                Task { await downloadPendingImages() }
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(K.HomeView.noEventsYet)
                    .font(.title)
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: "calendar.badge.clock")
            }
        }
        .foregroundStyle(.white)
    }

    private var categoryMenuView: some View {
        Menu {
            Button {
                categoryManager.selectedCategoryId = nil
            } label: {
                HStack {
                    Text(K.HomeView.all)
                    if categoryManager.selectedCategoryId == nil {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(categoryManager.categories) { category in
                Button {
                    categoryManager.selectedCategoryId = category.id
                } label: {
                    HStack {
                        Text(category.name)
                        if categoryManager.selectedCategoryId == category.id {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

            Divider()
                Button {
                    showingManageCategories = true
                } label: {
                    Label(K.HomeView.manageCategories, systemImage: "pencil")
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
               ForEach(futureEvents) { event in
                   eventRow(for: event)
                       .listRowSeparator(.hidden)
               }
               .onDelete { indexSet in
                   let ids = indexSet.map { futureEvents[$0].id }
                   eventStore.delete(withIds: ids)
               }
    
               if !futureEvents.isEmpty && !pastEvents.isEmpty {
                   pastSeparator
                       .listRowBackground(Color.clear)
                       .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                       .deleteDisabled(true)
               }
    
               ForEach(pastEvents) { event in
                   eventRow(for: event)
                       .listRowSeparator(.hidden)
               }
               .onDelete { indexSet in
                   let ids = indexSet.map { pastEvents[$0].id }
                   eventStore.delete(withIds: ids)
               }
           }
           .listRowSpacing(8)
           .listStyle(.plain)
           .scrollContentBackground(.hidden)
           .safeAreaInset(edge: .top) {
               VStack(spacing: 0) {
                   TipView(widgetTip)
                       .padding(.horizontal, 16)
                       .padding(.top, 8)
                   Color.clear.frame(height: 8)
                   Divider().background(Color.white.opacity(0.2))
               }
               .background(Color(hex: K.Colors.appBackground) ?? .black)
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
        else { return K.HomeView.all }
        return category.name
    }
    
    private func categoryColor(for event: Event) -> Color {
        guard let id = event.categoryID,
              let category = categoryManager.categories.first(where: { $0.id == id }) else {
            return .black
        }
        return Color(hex: category.color) ?? .black
    }
    
    private func categoryColorHex(for event: Event) -> String? {
        guard let id = event.categoryID,
              let category = categoryManager.categories.first(where: { $0.id == id }) else { return nil }
        return category.color
    }
    
    private var futureEvents: [Event] {
        filteredEvents.filter { $0.date >= Date() }.sorted { $0.date < $1.date }
    }

    private var pastEvents: [Event] {
        filteredEvents.filter { $0.date < Date() }.sorted { $0.date > $1.date }
    }
    
    private var pastSeparator: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(.white.opacity(0.5))
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

    private func eventRow(for event: Event) -> some View {
        NavigationLink {
            EditorView(event: event, initialCategoryColor: categoryColor(for: event) != .black ? categoryColor(for: event) : Color(hex: K.Colors.appBackground) ?? .black) { updatedEvent in
                eventStore.update(updatedEvent)
            }
        } label: {
            EventView(event: event)
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        .listRowBackground(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(categoryGradient(hex: categoryColorHex(for: event), opacity: 0.25))
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            }
            .padding(.horizontal, 8)
        )
    }
    
    private func syncWidgetEvents() {
        let widgetEvents = eventStore.events.map { event in
            let category = categoryManager.categories.first { $0.id == event.categoryID }
            return WidgetEvent(
                id: event.id,
                name: event.name,
                date: event.date,
                categoryName: category?.name,
                categoryColor: category?.color
            )
        }
        WidgetDataStore.saveAllEvents(widgetEvents)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func downloadPendingImages() async {
        for event in eventStore.events where !event.imageName.isLocalImage {
            if let localURL = await URL.saveImageFromURL(event.imageName) {
                var updatedEvent = event
                updatedEvent.imageName = localURL
                eventStore.update(updatedEvent)
            }
        }
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
