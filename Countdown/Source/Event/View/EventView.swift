//
//  EventView.swift
//  Countdown
//

import SwiftUI

struct EventView: View {
    let event: Event
    @EnvironmentObject var categoryManager: CategoryManager
    @StateObject private var network = NetworkMonitor()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Image
            Group {
                if event.displayMode == .emoji {
                    eventEmoji
                        .frame(height: 100)
                } else {
                    eventImage
                        .frame(height: 250)
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()

            // MARK: - Bottom section
            VStack(alignment: .leading, spacing: 8) {

                // Badge + date sur la même ligne
                HStack(alignment: .center) {
                    if let id = event.categoryID,
                       let category = categoryManager.categories.first(where: { $0.id == id }) {
                        Text(category.name.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(Color(hex: category.color) ?? .white)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text(event.date, style: .date)
                        Text("·")
                        Text(event.date, style: .time)
                    }
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                }

                TimelineView(.everyMinute) { _ in
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        if !isUnder24Hours {
                            Text("\(dayNumber)")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(.white)
                            
                            Text("\(dayNumber < 2 ? "day" : "days") \(isInFuture ? "to" : "since")")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.white.opacity(0.5))
                            
                        } else {
                            Text("\(hourNumber)")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(.white)
                            
                            Text("h")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            Text("\(minuteNumber)")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(.white)
                            
                            Text("min \(isInFuture ? "to" : "since")")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        
                        Text(event.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                }

                progressBar
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color(hex: K.Colors.editorBackground) ?? .black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 3)

                Capsule()
                    .fill(categoryColor)
                    .frame(width: geo.size.width * progressFraction, height: 3)
            }
        }
        .frame(height: 3)
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
                placeholderImage
            }
        } else if network.isConnected {
            AsyncImage(url: event.imageName) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                placeholderImage
            }
        } else {
            placeholderImage
        }
    }
    
    private var eventEmoji: some View {
        ZStack {
            LinearGradient(
                colors: [categoryColor.opacity(0.35), categoryColor.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(event.emoji ?? "✈️")
                .font(.system(size: 70))
        }
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.2))
            )
    }

    // MARK: - Computed properties

    private var isLocalImage: Bool {
        event.imageName.isLocalImage
    }

    private var displayImage: UIImage? {
        guard isLocalImage,
              let filename = event.imageName.localFilename,
              let fileURL = URL.localImageURL(filename: filename) else { return nil }
        let targetSize = CGSize(width: 400 * 3, height: 200 * 3)
        return UIImage().downsampledImage(at: fileURL, targetSize: targetSize)
    }

    private var isInFuture: Bool {
        event.date >= Date()
    }

    private var dayNumber: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDay = calendar.startOfDay(for: event.date)
        return abs(calendar.dateComponents([.day], from: today, to: eventDay).day ?? 0)
    }

    private var isUnder24Hours: Bool {
        abs(event.date.timeIntervalSinceNow) < 86400
    }

    private var hourNumber: Int {
        let interval = abs(event.date.timeIntervalSince(Date()))
        let hours = (Int(ceil(interval / 60) * 60) % 86400) / 3600
        return hours
    }
    
    private var minuteNumber: Int {
        let interval = abs(event.date.timeIntervalSince(Date()))
        let minutes = (Int(ceil(interval / 60) * 60) % 3600) / 60
        return minutes
    }


    private var progressFraction: CGFloat {
        let total: TimeInterval = 50 * 86400
        let remaining = max(event.date.timeIntervalSince(Date()), 0)
        let elapsed = total - min(remaining, total)
        return CGFloat(elapsed / total)
    }

    private var categoryColor: Color {
        if let id = event.categoryID,
           let category = categoryManager.categories.first(where: { $0.id == id }) {
            return Color(hex: category.color) ?? .white
        }
        return .white
    }
}

#Preview {
    let event = Event(id: UUID(), name: "Trip to Tokyo", date: Date().addingTimeInterval(86400 * 12), imageName: URL(string: "https://picsum.photos/seed/1/400/140")!)
    EventView(event: event)
        .padding()
        .background(Color(hex: "#0D0D14") ?? .black)
}
