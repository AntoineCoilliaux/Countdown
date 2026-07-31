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
            VStack(spacing: 0) {
                CategorySelectorView(
                    selectedCategoryId: $categoryManager.selectedCategoryId,
                    onManageCategories: { showingManageCategories = true },
                    showAllOption: true
                )
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.black)
                
                if filteredEvents.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    eventList
                }
            }
            .background(.black)
            .toolbar { ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditorView { newEvent in
                        eventStore.add(newEvent) }
                } label: {
                    Image(systemName: "plus")
                }
                    .buttonStyle(.borderedProminent)
                .tint(.blue) }
            }
            
            .sheet(isPresented: $showingManageCategories) {
                ManageCategoriesView()
            }
            
            .onChange(of: eventStore.events) { oldEvents, newEvents in if oldEvents.isEmpty && newEvents.count == 1 {
                Task { await WidgetTip.firstEventCreated.donate() }
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
    
    private var eventList: some View {
        TimelineView(.everyMinute) { timelineContext in
            let currentInstant = timelineContext.date
            
            List {
                ForEach(filteredEvents.filter { $0.date >= currentInstant }.sorted { $0.date < $1.date }) { event in
                    eventRow(for: event, currentDate: currentInstant)
                        .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    let futureEvents = filteredEvents.filter { $0.date >= currentInstant }.sorted { $0.date < $1.date }
                    let ids = indexSet.map { futureEvents[$0].id }
                    eventStore.delete(withIds: ids)
                }
                
                if !filteredEvents.filter({ $0.date >= currentInstant }).isEmpty &&
                    !filteredEvents.filter({ $0.date < currentInstant }).isEmpty {
                    pastSeparator
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .deleteDisabled(true)
                }
                
                ForEach(filteredEvents.filter { $0.date < currentInstant }.sorted { $0.date > $1.date }) { event in
                    eventRow(for: event, currentDate: currentInstant)
                        .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    let pastEvents = filteredEvents.filter { $0.date < currentInstant }.sorted { $0.date > $1.date }
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
                    Divider()
                }
                .background(.black)
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
    
    private var pastSeparator: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(.white.opacity(0.5))
            .frame(height: 1)
            .padding(.horizontal, 12)
    }
    
    private func eventRow(for event: Event, currentDate: Date) -> some View {
        ZStack {
            NavigationLink {
                EventDetailView(event: event)
            } label: {
                EmptyView()
            }
            .opacity(0)

            EventView(event: event, currentDate: currentDate)
                .id("\(event.id)-\(currentDate.timeIntervalSince1970)")
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
        .listRowBackground(Color.clear)
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
    
    private func resizeForWidget(_ image: UIImage) -> UIImage {
        // Le widget medium fait ~160pt de large côté image, @3x = 480px max
        let targetSize = CGSize(width: 160, height: 160)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func syncWidgetEvents() {
        let widgetEvents = eventStore.events.map { event in
            let category = categoryManager.categories.first { $0.id == event.categoryID }
            
            let imageData: Data?
            if event.displayMode == .photo,
               let filename = event.imageName.localFilename,
               let fileURL = URL.localImageURL(filename: filename) {
                let raw = try? Data(contentsOf: fileURL)
                imageData = raw
                    .flatMap { UIImage(data: $0) }
                    .flatMap { resizeForWidget($0) }
                    .flatMap { $0.jpegData(compressionQuality: 0.5) }
            } else {
                imageData = nil
            }
            
            return WidgetEvent(
                id: event.id,
                name: event.name,
                date: event.date,
                categoryName: category?.name,
                categoryColor: category?.color,
                emoji: event.emoji,
                imageName: event.imageName,
                imageData: imageData,
                displayMode: event.displayMode
            )
        }
        WidgetDataStore.saveAllEvents(widgetEvents)
        WidgetCenter.shared.reloadAllTimelines()
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
