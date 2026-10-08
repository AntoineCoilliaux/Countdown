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
    @AppStorage("compactHomeView") private var useCompactView: Bool = false

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
                    TimelineView(.everyMinute) { context in
                        eventList(now: context.date)
                    }
                }
            }
            .background(.black)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        useCompactView.toggle()
                    } label: {
                        Image(systemName: useCompactView ? "rectangle.grid.1x2" : "rectangle.grid.1x3")
                    }
                    .accessibilityLabel("Switch layout")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EditorView { eventStore.add($0) }
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

    /// Liste unique, partagée entre la vue compacte et la vue normale.
    private func eventList(now: Date) -> some View {
        let upcoming = filteredEvents.filter { $0.date >= now }.sorted { $0.date < $1.date }
        let past = filteredEvents.filter { $0.date < now }.sorted { $0.date > $1.date }

        return List {
            eventRows(upcoming, now: now)

            if !upcoming.isEmpty && !past.isEmpty {
                pastSeparator
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .deleteDisabled(true)
            }

            eventRows(past, now: now)
        }
        .listRowSpacing(useCompactView ? 0 : 8)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .top) { tipHeader }
    }

    private func eventRows(_ events: [Event], now: Date) -> some View {
        ForEach(events) { event in
            row(for: event, now: now)
                .id("\(event.id)-\(now.timeIntervalSince1970)")
        }
        .onDelete { offsets in
            eventStore.delete(withIds: offsets.map { events[$0].id })
        }
    }

    @ViewBuilder
    private func row(for event: Event, now: Date) -> some View {
        if useCompactView {
            CompactEventRow(event: event, now: now)
        } else {
            ZStack {
                NavigationLink {
                    EventDetailView(event: event)
                } label: {
                    EmptyView()
                }
                .opacity(0)

                EventView(event: event, currentDate: now)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
            .listRowBackground(Color.clear)
        }
    }

    private var tipHeader: some View {
        VStack(spacing: 0) {
            TipView(widgetTip)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            Color.clear.frame(height: 8)
            Divider()
        }
        .background(.black)
    }

    private var pastSeparator: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(.white.opacity(0.5))
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

    // MARK: - Helpers

    private var filteredEvents: [Event] {
        guard let id = categoryManager.selectedCategoryId else {
            return eventStore.events
        }
        return eventStore.events.filter { $0.categoryID == id }
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
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
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
                imageData = (try? Data(contentsOf: fileURL))
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

    // MARK: - CompactEventRow

    /// Carte horizontale compacte d'un événement.
    private struct CompactEventRow: View {
        let event: Event
        let now: Date

        @EnvironmentObject private var categoryManager: CategoryManager

        private var daysRemaining: Int {
            let calendar = Calendar.current
            return abs(calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: now),
                to: calendar.startOfDay(for: event.date)
            ).day ?? 0)
        }

        /// Progression de createdAt à la date de l'événement, entre 0 et 1.
        private var progress: CGFloat {
            guard let createdAt = event.createdAt else { return 0 }
            let total = event.date.timeIntervalSince(createdAt)
            guard total > 0 else { return 1 }
            return min(max(CGFloat(now.timeIntervalSince(createdAt) / total), 0), 1)
        }

        private var categoryColor: Color {
            guard let hex = categoryManager.categories
                .first(where: { $0.id == event.categoryID })?.color
            else { return .white }
            return Color(hex: hex) ?? .white
        }

        // MARK: Parties de la ligne

        @ViewBuilder
        private var imageOrEmojiView: some View {
            if event.displayMode == .photo,
               let filename = event.imageName.localFilename,
               let fileURL = URL.localImageURL(filename: filename),
               let data = try? Data(contentsOf: fileURL),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(event.emoji ?? "✈️")
                    .font(.system(size: 32))
                    .frame(width: 48, height: 48)
                    .background(categoryColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }

        private var titleAndDateView: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(event.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(categoryColor.opacity(0.7))
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        /// Nombre (même taille pour jours, heures et minutes) suivi d'une unité optionnelle.
        private func value(_ number: String, unit: String? = nil) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(number)
                    .font(.headline.monospacedDigit())
                    .foregroundColor(categoryColor)
                if let unit {
                    Text(unit)
                        .font(.caption.bold())
                        .foregroundColor(categoryColor.opacity(0.8))
                }
            }
        }

        private var remainingTimeView: some View {
            Group {
                if event.isUnder24Hours {
                    HStack(spacing: 6) {
                        value("\(event.hourNumber())", unit: "h")
                        value("\(event.minuteNumber(includeSeconds: false))", unit: "min")
                    }
                } else {
                    value("\(daysRemaining)")
                }
            }
            .frame(minWidth: 40, alignment: .trailing)
        }

        private var progressBar: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                    RoundedRectangle(cornerRadius: 1)
                        .fill(categoryColor)
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 3)
            .clipShape(RoundedRectangle(cornerRadius: 1))
            .padding(.horizontal, 12)
            .padding(.bottom, 2)
        }

        var body: some View {
            NavigationLink(destination: EventDetailView(event: event)) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        imageOrEmojiView
                        titleAndDateView
                        remainingTimeView
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.8))
                    )

                    progressBar
                }
            }
            .buttonStyle(PlainButtonStyle())
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
