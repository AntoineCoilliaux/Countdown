//
//  ContentView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI

struct EventView: View {
    let event: Event
    @EnvironmentObject var categoryManager: CategoryManager
    @StateObject private var network = NetworkMonitor()

    var body: some View {
        HStack(spacing: 0) {
            eventImage
                .frame(width: 62, height: 47)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4), lineWidth: 1))
                .padding(.horizontal, 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(event.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Text(event.date, style: .date)
                    Text("·")
                    Text(event.date, style: .time)
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.55))

                if let id = event.categoryID,
                   let category = categoryManager.categories.first(where: { $0.id == id }) {
                    Text(category.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            TimelineView(.everyMinute) { _ in
                countdownView
            }
            .padding(.trailing, 4)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var eventImage: some View {
        if isLocalImage {
            if let uiImage = displayImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
            }
        } else if network.isConnected {
            AsyncImage(url: event.imageName) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
        }
    }

    private var countdownView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 3) {
                Text(dayNumber)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(isInFuture ? Color(hex: K.Colors.green) ?? .green : Color(hex: K.Colors.red) ?? .red)
                Image(systemName: isInFuture ? "arrow.down" : "arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(remainingText)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(isInFuture ? Color(hex: K.Colors.green) ?? .green : Color(hex: K.Colors.red) ?? .red)
        }
    }

    // MARK: - Computed properties

    private var isLocalImage: Bool {
        event.imageName.isLocalImage
    }

    private var displayImage: UIImage? {
        guard isLocalImage,
              let filename = event.imageName.localFilename,
              let fileURL = URL.localImageURL(filename: filename) else { return nil }
        
        let targetSize = CGSize(width: 56 * 3, height: 56 * 3)
        return UIImage().downsampledImage(at: fileURL, targetSize: targetSize)
    }

    private var isInFuture: Bool {
        event.date >= Date()
    }

    private var dayNumber: String {
        let interval = abs(event.date.timeIntervalSince(Date()))
        let days = Int(ceil(interval / 60) * 60) / 86400
        return "\(days)"
    }

    private var remainingText: String {
        let interval = abs(event.date.timeIntervalSince(Date()))
        let roundedInterval = ceil(interval / 60) * 60
        let hours = (Int(roundedInterval) % 86400) / 3600
        let minutes = (Int(roundedInterval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

#Preview {
    let event = Event(id: UUID(), name: "Test Event", date: Date(), imageName: URL(string: "https://picsum.photos/seed/1/300/300")!)
    EventView(event: event)
}
