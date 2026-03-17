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
    @Published var newCategoryName: String = ""
    
    var randomNumber = Int.random(in: 0...100)
    let characterLimit: Int = 35

    enum Mode {
        case add
        case edit(existing: Event)
    }

    let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            self.name = ""
            self.date = Date()
            self.imageName = URL(string: "https://picsum.photos/seed/\(randomNumber)/300/300")!
            self.selectedCategoryId = nil
        case .edit(let existing):
            self.name = existing.name
            self.date = existing.date
            self.imageName = existing.imageName
            self.selectedCategoryId = existing.categoryID
        }
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count < characterLimit
    }
    
    var canSaveCategory: Bool {
        !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && newCategoryName.count < characterLimit
    }
    
    var isLocalImage: Bool {
        imageName.isLocalImage
    }
    
    var displayImage: UIImage? {
        guard isLocalImage,
              let filename = imageName.localFilename,
              let fileURL = URL.localImageURL(filename: filename) else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func createCategory(in categoryManager: CategoryManager) -> Category? {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= characterLimit else { return nil }
        
        let newCategory = Category(id: UUID(), name: trimmed)
        categoryManager.addCategory(newCategory)
        selectedCategoryId = newCategory.id
        newCategoryName = ""
        
        return newCategory
    }
    
    func resetNewCategoryName() {
        newCategoryName = ""
    }

    func save() throws -> Event {
        switch mode {
        case .add:
            return Event(
                id: UUID(),
                name: name,
                date: date,
                imageName: imageName,
                categoryID: selectedCategoryId
            )
        case .edit(let existing):
            return Event(
                id: existing.id,
                name: name,
                date: date,
                imageName: imageName,
                categoryID: selectedCategoryId
            )
        }
    }
}
