//
//  CompactEventRow.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 09/10/2026.
//

import SwiftUI

struct CompactEventRow: View {
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
        else { return Color.textPrimary }
        return Color.category(hex: hex)
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
                .foregroundColor(Color.textPrimary)
                .lineLimit(2)
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
                .font(.system(size: 26, weight: .semibold).monospacedDigit())
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
                    value(String(format: "%02d", event.minuteNumber(includeSeconds: false)), unit: "min")
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
                    .fill(Color.textPrimary.opacity(0.10))
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
                        .fill(Color(light: .white, dark: Color.black.opacity(0.8)))
                )

                progressBar
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
