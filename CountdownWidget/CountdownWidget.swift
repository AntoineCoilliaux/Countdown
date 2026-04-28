//
//  CountdownWidget.swift
//  CountdownWidget
//
//  Created by Antoine Coilliaux on 22/04/2026.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - App Intent (La Configuration)

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title = K.CountdownWidget.appIntentTitle
    static var description = K.CountdownWidget.appIntentDescription

    // C'est ce paramètre qui crée le menu de sélection
    @Parameter(title: K.CountdownWidget.parameterTitle)
    var event: EventEntity?
}

// MARK: - App Entity (Le pont entre tes données et iOS)

struct EventEntity: AppEntity, Identifiable {
    let id: UUID
    let name: String
    
    static var typeDisplayRepresentation = K.CountdownWidget.typeDisplayRepresentation
    static var defaultQuery = EventQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct EventQuery: EntityQuery {
    // Permet de retrouver l'événement sélectionné par son ID
    func entities(for identifiers: [UUID]) async throws -> [EventEntity] {
        let allEvents = WidgetDataStore.loadAllEvents() // Tu devras créer cette méthode
        return allEvents
            .filter { identifiers.contains($0.id) }
            .map { EventEntity(id: $0.id, name: $0.name) }
    }
    
    // Permet d'afficher la liste complète dans le menu de sélection
    func suggestedEntities() async throws -> [EventEntity] {
        let allEvents = WidgetDataStore.loadAllEvents()
        return allEvents.map { EventEntity(id: $0.id, name: $0.name) }
    }
}

// MARK: - Timeline Entry

struct CountdownEntry: TimelineEntry {
    let date: Date
    let widgetEvent: WidgetEvent?
}

// MARK: - Provider (AppIntentTimelineProvider)

struct CountdownProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(
            date: Date(),
            widgetEvent: WidgetEvent(
                id: UUID(),
                name: "Example",
                date: Date().addingTimeInterval(86400),
                categoryName: "Birthday",
                categoryColor: "#1E3A5F"
            )
        )
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> CountdownEntry {
        let event = loadEvent(from: configuration)
        return CountdownEntry(date: Date(), widgetEvent: event)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<CountdownEntry> {
        let widgetEvent = loadEvent(from: configuration)
        let now = Date()
        var entries: [CountdownEntry] = []

        // 1. Entrée pour l'état actuel
        entries.append(CountdownEntry(date: now, widgetEvent: widgetEvent))

        // 2. Si l'événement est dans le futur, on prévoit une mise à jour pile au moment T
        if let eventDate = widgetEvent?.date, eventDate > now {
            // On ajoute une entrée à la seconde exacte de l'événement
            // Cela forcera le widget à recalculer 'isInFuture' qui deviendra false
            entries.append(CountdownEntry(date: eventDate, widgetEvent: widgetEvent))
        }

        // On rafraîchit la timeline dans 12h pour la maintenance générale
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 12, to: now) ?? now
        
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
    
    // Helper pour charger l'événement spécifique choisi par l'utilisateur
    private func loadEvent(from configuration: SelectEventIntent) -> WidgetEvent? {
        if let selectedId = configuration.event?.id {
            return WidgetDataStore.loadSpecificEvent(id: selectedId)
        }
        return WidgetDataStore.loadAllEvents()
                .filter { $0.date >= Date() }
                .sorted { $0.date < $1.date }
                .first
    }
}

// MARK: - Widget View

struct CountdownWidgetView: View {
    let entry: CountdownEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let event = entry.widgetEvent {
            widgetEventView(for: event)
        } else {
            emptyView
        }
    }
    
    private func widgetEventView(for event: WidgetEvent) -> some View {
        let isActuallyInFuture = event.date > entry.date
        
        return VStack(alignment: .center, spacing: 3) {
            Text(event.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .layoutPriority(1)
            VStack {
                Text(event.date, style: .date)
                Text(event.date, style: .time)
            }
            .font(.system(size: 10.5, weight: .regular))
            .foregroundStyle(.white.opacity(0.45))
            Spacer(minLength: 0)

            Text(event.date, style: .relative)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(isActuallyInFuture ? (Color(hex: K.Colors.green) ?? .green) : (Color(hex: K.Colors.red) ?? .red))
                .multilineTextAlignment(.center)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .containerBackground(for: .widget) {
            backgroundGradient(for: event)
        }
    }
        
    private func backgroundGradient(for event: WidgetEvent) -> some View {
        let base = event.categoryColor.flatMap { Color(hex: $0) } ?? .black
        return LinearGradient(
            colors: [base, base.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.5))
            Text(K.CountdownWidget.noEventSelected)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .containerBackground(for: .widget) {
            Color(hex: K.Colors.appBackground) ?? .black
        }
    }
}

// MARK: - Widget Configuration

@main
struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"

    var body: some WidgetConfiguration {
        // Changement ici : AppIntentConfiguration
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: CountdownProvider()
        ) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName(K.CountdownWidget.displayName)
        .description(K.CountdownWidget.description)
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemMedium) {
    CountdownWidget()
} timeline: {
    CountdownEntry(
        date: .now,
        widgetEvent: WidgetEvent(
            id: UUID(),
            name: "Japanese GP",
            date: Date().addingTimeInterval(-3599),
            categoryName: nil,
            categoryColor: nil
        )
    )
}
