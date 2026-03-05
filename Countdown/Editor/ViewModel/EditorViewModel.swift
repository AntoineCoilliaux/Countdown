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
    @Published var newCategoryName: String = ""  // ✅ Déplace ici
    
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
    
    // ✅ Logique de validation de catégorie
    var canSaveCategory: Bool {
        !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // ✅ Computed properties pour l'affichage de l'image
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
    
    // ✅ Méthode pour créer une catégorie
    func createCategory(in categoryManager: CategoryManager) -> Category? {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let newCategory = Category(id: UUID(), name: trimmed)
        categoryManager.addCategory(newCategory)
        selectedCategoryId = newCategory.id
        newCategoryName = ""  // Reset
        
        return newCategory
    }
    
    // ✅ Méthode pour reset le nom de catégorie
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
                categoryID: selectedCategoryId  // ✅ Utilise la catégorie sélectionnée
            )
        case .edit(let existing):
            return Event(
                id: existing.id,
                name: name,
                date: date,
                imageName: imageName,
                categoryID: selectedCategoryId  // ✅ Permet de changer la catégorie
            )
        }
    }
}
