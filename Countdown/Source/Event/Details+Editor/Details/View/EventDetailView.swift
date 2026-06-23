//
//  EventDetailView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 16/06/2026.
//

import SwiftUI

struct EventDetailView: View {
    @State var event: Event
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingEditor = false

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                mediaSection

                VStack(alignment: .leading, spacing: 25) {
                    badgeView
                    
                    Text(event.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(event.formattedFullDate)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.45))
                    
                    TimelineView(.animation) { _ in
                        countdownRow
                        progressSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingEditor = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            EditorView(event: event, initialCategoryColor: categoryColor) { updatedEvent in
                event = updatedEvent
                eventStore.update(updatedEvent)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var mediaSection: some View {
        EventMediaView(
            displayMode: event.displayMode ?? .photo,
            emoji: event.emoji,
            categoryColor: categoryColor,
            emojiHeight: 100,
            photoHeight: 170
        ) {
            eventImage
        }
    }

    @ViewBuilder
    private var eventImage: some View {
        if event.imageName.isLocalImage,
           let filename = event.imageName.localFilename,
           let fileURL = URL.localImageURL(filename: filename),
           let uiImage = UIImage().downsampledImage(at: fileURL, targetSize: CGSize(width: 1200, height: 600)) {
            Image(uiImage: uiImage).resizable()
        } else {
            AsyncImage(url: event.imageName) { image in
                image.resizable()
            } placeholder: {
                Rectangle().fill(Color.white.opacity(0.05))
            }
        }
    }

    private var badgeView: some View {
        Group {
            if let id = event.categoryID,
               let category = categoryManager.categories.first(where: { $0.id == id }) {
                Text(category.name.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color(hex: category.color) ?? .white))
            }
        }
    }

    private var countdownRow: some View {
        HStack(spacing: 8) {
            countdownBox(value: event.isUnder24Hours ? 0 : event.dayNumber(includeHours: true), label: event.dayNumber (includeHours: true) > 1 ? K.EventDetailView.countdownRowDays : K.EventDetailView.countdownRowDay)
            countdownBox(value: event.hourNumber(includeSeconds: true), label: K.EventDetailView.countdownRowHours)
            countdownBox(value: event.minuteNumber(includeSeconds: true), label: K.EventDetailView.countdownRowMinutes)
            countdownBox(value: event.secondNumber, label: K.EventDetailView.countdownRowSeconds, accent: true)
        }
    }

    private func countdownBox(value: Int, label: String, accent: Bool = false) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(accent ? (categoryColor) : .white)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if event.isInFuture {
                    Text("\(Int(event.progressFraction * 100))\(K.EventDetailView.progressSectionFuture)")                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.35))
                } else {
                    Text(K.EventDetailView.progressSectionPast)
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.35))
                }
                
                Spacer()
                Text("\(Int(event.progressFraction * 100))%")
                    .foregroundStyle(categoryColor)
            }
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.35))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 3)
                    Capsule().fill(categoryColor).frame(width: geo.size.width * event.progressFraction, height: 3)
                }
            }
            .frame(height: 3)
        }
    }

    private var categoryColor: Color {
        if let id = event.categoryID,
           let category = categoryManager.categories.first(where: { $0.id == id }) {
            return Color(hex: category.color) ?? .white
        }
        return .white
    }
}
