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
    @Published var selectionState: CategorySelectionState = .reading

    @Published var name: String
    @Published var color: String?
    @Published var date: Date
    @Published var imageName: URL
    @Published var selectedCategoryId: UUID?
    @Published var categoryName: String = ""
    @Published var showSaveError: Bool = false
    @Published var emoji: String = ""
    @Published var displayMode: EventDisplayMode = .photo
    
    let mode: Mode
    
    enum CategorySelectionState {
        case reading, creating, editing
    }
    
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
            self.emoji = K.Emojis.categories.flatMap { $0.emojis }.randomElement() ?? "✈️"
            self.selectedCategoryId = nil
        case .edit(let existing):
            self.name = existing.name
            self.date = existing.date
            self.imageName = existing.imageName
            self.selectedCategoryId = existing.categoryID
            self.displayMode = existing.displayMode ?? .photo
            self.emoji = existing.emoji ?? "✈️"
        }
    }

    func startCreating() {
        resetNewCategoryName()
        selectionState = .creating
    }

    func startEditing(category: Category) {
        categoryName = category.name
        color = category.color
        selectionState = .editing
    }

    func cancelCategoryAction() {
        resetNewCategoryName()
        selectionState = .reading
    }
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var isPlaceholderImage: Bool {
        imageName.absoluteString.contains("picsum.photos") && !imageName.isLocalImage
    }
    
    let randomNumber = Int.random(in: 1...100)
    let characterLimit: Int = 35
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !eventTitleIsTooLong
    }
    
    var eventTitleIsTooLong: Bool {
        name.count > characterLimit
    }
    
    var categoryNameIsTooLong : Bool {
        categoryName.count > characterLimit
    }
    
    var categoryNameIsValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !categoryNameIsTooLong
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
    
    func createCategory(in categoryManager: CategoryManager) -> Category? {
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= characterLimit else { return nil }
        
        let newCategory = Category(id: UUID(), name: trimmed, color: color ?? K.Colors.defaultCategoryHex)
        categoryManager.addCategory(newCategory)
        selectedCategoryId = newCategory.id
        resetNewCategoryName()
        color = nil
        
        return newCategory
    }
    
    func saveCategory(in categoryManager: CategoryManager, hex: String) {
        color = hex
        switch selectionState {
        case .editing:
            updateCategory(in: categoryManager)
        case .creating:
            _ = createCategory(in: categoryManager)
        case .reading:
            break
        }
        selectionState = .reading
    }
    
    func updateCategory(in categoryManager: CategoryManager) {
        guard let id = selectedCategoryId else { return }
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= characterLimit else { return }
        
        let updatedCategory = Category(id: id, name: trimmed, color: color ?? K.Colors.defaultCategoryHex)
        categoryManager.updateCategory(updatedCategory)
        resetNewCategoryName()
    }
    
    func resetNewCategoryName() {
        categoryName = ""
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

