//
//  EditorViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 05/02/2026.
//

import Combine
import Foundation
import SwiftUI

final class EditorViewModel: ObservableObject {

    @Published var name: String
    @Published var date: Date
    @Published var imageName: URL
    @Published var selectedCategoryId: UUID?
    @Published var showSaveError: Bool = false
    @Published var emoji: String = ""
    @Published var displayMode: EventDisplayMode = .emoji
    @Published var reminders: [ReminderOption] = []

    let mode: Mode
    let randomNumber = Int.random(in: 1...100)
    let characterLimit: Int = 35
    
    enum Mode {
        case add
        case edit(existing: Event)
    }

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            self.name = ""
            self.date = Date()
            self.imageName = URL(string: "https://picsum.photos/seed/\(randomNumber)/300/300") ?? URL(string: "https://picsum.photos/seed/1/300/300")!
            self.emoji = EmojiLibrary.shared.all.randomElement()?.emoji ?? "✈️"
            self.selectedCategoryId = nil
            self.reminders = []
        case .edit(let existing):
            self.name = existing.name
            self.date = existing.date
            self.imageName = existing.imageName
            self.selectedCategoryId = existing.categoryID
            self.displayMode = existing.displayMode ?? .emoji
            self.emoji = existing.emoji ?? "✈️"
            self.reminders = existing.reminders
        }
    }
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var remindersSummary: String {
        let filtered = reminders.filter { $0 != .now }
        guard !filtered.isEmpty else { return "Never" }
        return filtered.map { $0.label }.joined(separator: ", ")
    }
    
    var isPlaceholderImage: Bool {
        imageName.absoluteString.contains("picsum.photos") && !imageName.isLocalImage
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !eventTitleIsTooLong
    }
    
    var eventTitleIsTooLong: Bool {
        name.count > characterLimit
    }
    
    var isLocalImage: Bool {
        imageName.isLocalImage
    }
    
    var displayImage: UIImage? {
        guard isLocalImage,
              let filename = imageName.localFilename,
              let fileURL = URL.localImageURL(filename: filename) else { return nil }
        
        let targetSize = CGSize(width: 400 * 3, height: 200 * 3)
        return UIImage().downsampledImage(at: fileURL, targetSize: targetSize)
    }
    
    func save() async -> Event? {
        var finalImageURL = imageName
        if !imageName.isLocalImage {
            if let localURL = await URL.saveImageFromURL(imageName) {
                finalImageURL = localURL
            } else if isPlaceholderImage {
                finalImageURL = imageName
            } else {
                showSaveError = true
                return nil
            }
        }
        
        switch mode {
        case .add:
            return Event(
                id: UUID(),
                name: name,
                date: date,
                createdAt: Date(),
                imageName: finalImageURL,
                categoryID: selectedCategoryId,
                emoji: emoji.isEmpty ? nil : String(emoji.prefix(1)),
                displayMode: displayMode,
                reminders: reminders
            )
        case .edit(let existing):
            let dateChanged = existing.date != date
            return Event(
                id: existing.id,
                name: name,
                date: date,
                createdAt: dateChanged ? Date() : existing.createdAt,
                imageName: finalImageURL,
                categoryID: selectedCategoryId,
                emoji: emoji.isEmpty ? nil : String(emoji.prefix(1)),
                displayMode: displayMode,
                reminders: reminders
            )
        }
    }
    
    @MainActor
    func selectRemoteImage(_ remoteURL: URL) async {
        imageName = remoteURL
        if let localURL = await URL.saveImageFromURL(remoteURL) {
            imageName = localURL
        }
    }
}
