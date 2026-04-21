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

    @State private var showingManageCategories = false

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
    
    private var futureEvents: [Event] {
        filteredEvents.filter { $0.date >= Date() }.sorted { $0.date < $1.date }
    }

    private var pastEvents: [Event] {
        filteredEvents.filter { $0.date < Date() }.sorted { $0.date > $1.date }
    }
    
    private var pastSeparator: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.red.opacity(0.5))
                .frame(height: 0.5)
                .overlay(
                    GeometryReader { geo in
                        Path { path in
                            var x: CGFloat = 0
                            while x < geo.size.width {
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x + 4, y: 0))
                                x += 8
                            }
                        }
                        .stroke(Color.red.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }
                )
            }
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
                    .fill(categoryColor(for: event))
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(Color.black, lineWidth: 1)
            }
            .padding(.horizontal, 8)
        )
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
