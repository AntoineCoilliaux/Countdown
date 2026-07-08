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
    static var title : LocalizedStringResource = "Pick an event"
    static var description = IntentDescription("Pick an event for your widget.") 

    // C'est ce paramètre qui crée le menu de sélection
    @Parameter(title: "Select an event")
    var event: EventEntity?
}

// MARK: - App Entity (Le pont entre tes données et iOS)

struct EventEntity: AppEntity, Identifiable {
    let id: UUID
    let name: String
    
    static var typeDisplayRepresentation : TypeDisplayRepresentation = "Event"
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
                name: "Your event",
                date: Date().addingTimeInterval(86400 * 12),
                categoryName: "Your category",
                categoryColor: "#C8F135",
                emoji: "🎉",
                imageName: nil,
                imageData: nil,
                displayMode: .emoji
            )
        )
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> CountdownEntry {
        if context.isPreview {
            return placeholder(in: context)
        }
        let event = loadEvent(from: configuration)
        return CountdownEntry(date: Date(), widgetEvent: event)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<CountdownEntry> {
        let widgetEvent = loadEvent(from: configuration)
        let now = Date()
        var entries: [CountdownEntry] = []

        entries.append(CountdownEntry(date: now, widgetEvent: widgetEvent))

        if let eventDate = widgetEvent?.date, eventDate > now {
            entries.append(CountdownEntry(date: eventDate, widgetEvent: widgetEvent))
        }

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 12, to: now) ?? now
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
    
    private func loadEvent(from configuration: SelectEventIntent) -> WidgetEvent? {
        guard let selectedId = configuration.event?.id else {
            return nil  // ← au lieu de charger le prochain event automatiquement
        }
        return WidgetDataStore.loadSpecificEvent(id: selectedId)
    }
}

// MARK: - Widget View

struct CountdownWidgetView: View {
    let entry: CountdownEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let event = entry.widgetEvent {
            switch family {
            case .systemMedium:
                widgetMediumView(for: event)
            default:
                widgetSmallView(for: event)
            }
        } else {
            emptyView
        }
    }
    
    private func widgetSmallView(for event: WidgetEvent) -> some View {
        let categoryColor = event.categoryColor.flatMap { Color(hex: $0) } ?? .white
        let isActuallyInFuture = event.isInFuture(relativeTo: entry.date)

        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(categoryColor)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let categoryName = event.categoryName {
                    Text(categoryName)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            if !isActuallyInFuture {
                Text(K.CountdownWidget.itsOn)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(categoryColor)
                    .lineLimit(3)
            } else {
                Text(event.date, style: .relative)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(categoryColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }

            Spacer(minLength: 8)
            
            HStack(spacing: 4) {
                Text(event.date, style: .date)
                Text("·")
                Text(event.date, style: .time)
            }
            .font(.system(size: 10, weight: .regular))
            .foregroundStyle(.white.opacity(0.45))
        }
        .padding(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Color(.black)
        }
    }
    
    private func widgetMediumView(for event: WidgetEvent) -> some View {
        let categoryColor = event.categoryColor.flatMap { Color(hex: $0) } ?? .white
        let isActuallyInFuture = event.isInFuture(relativeTo: entry.date)

        return HStack(alignment: .center, spacing: 4) {

            // Colonne gauche — nom, catégorie, countdown, date
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(categoryColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let categoryName = event.categoryName {
                    Text(categoryName)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer(minLength: 6)
                
                if !isActuallyInFuture {
                    Text(K.CountdownWidget.itsOn)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(categoryColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(event.date, style: .relative)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(categoryColor)
                        .lineLimit(2)
                }
                
                Spacer(minLength: 6)
                
                HStack(spacing: 4) {
                    Text(event.date, style: .date)
                    Text("·")
                    Text(event.date, style: .time)
                }
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                if event.displayMode == .emoji {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 70, height: 70)
                    
                    if let emoji = event.emoji {
                        Text(emoji)
                            .font(.system(size: 50))
                    } else {
                        Text(String(event.name.prefix(1)).uppercased())
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(categoryColor)
                    }
                } else {
                    if let data = event.imageData, let uiImage = UIImage(data: data) {
                          Image(uiImage: uiImage)
                              .resizable()
                              .scaledToFill()
                              .frame(height: 93)
                              .frame(width: 70)
                              .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.08))
                            .frame(width: 80)
                            .frame(maxHeight: .infinity)
                        Text(String(event.name.prefix(1)).uppercased())
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(categoryColor)
                    }
                }
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Color(.black)
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

//#Preview(as: .systemMedium) {
//    CountdownWidget()
//} timeline: {
//    CountdownEntry(
//        date: .now,
//        widgetEvent: WidgetEvent(
//            id: UUID(),
//            name: "Japanese GP",
//            date: Date().addingTimeInterval(-3599),
//            categoryName: nil,
//            categoryColor: nil,
//            emoji: "slightly smiling face"
//        )
//    )
//}
