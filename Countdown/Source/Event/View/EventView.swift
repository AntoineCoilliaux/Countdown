//
//  ContentView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI

struct EventView: View {
    let event: Event

    var body: some View {
        HStack {
            eventImage
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))

            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text(event.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(event.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            TimelineView(.everyMinute) { _ in
                countdownView
            }
        }
        .padding(.vertical, 3)
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
        } else {
            AsyncImage(url: event.imageName) { image in
                image
                    .resizable()
                
            } placeholder: {
                ProgressView()
            }
        }
    }

    private var countdownView: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text(dayNumber)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(isInFuture ? .green : .red)
                Image(systemName: isInFuture ? "arrow.down" : "arrow.up")
            }
            Text(remainingText)
                .font(.caption)
                .foregroundColor(isInFuture ? .green : .red)
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
        return UIImage(contentsOfFile: fileURL.path)
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
