//
//  ManageCategoriesViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 14/04/2026.
//

import Combine
import Foundation

final class ManageCategoriesViewModel: ObservableObject {
    
    enum SelectionState {
        case reading, creating, editing
    }
    
    @Published var selectionState: SelectionState = .reading
    @Published var categoryName: String = ""
    @Published var showDeleteAlert = false
    @Published var pendingDeleteEventCount: Int = 0
    @Published var selectedHex: String?
    
    var selectedCategoryId: UUID?
    private var categoryToDelete: Category?
    let characterLimit: Int = 35

    var categoryNameIsTooLong : Bool {
        categoryName.count > characterLimit
    }
    
    var categoryNameIsValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !categoryNameIsTooLong
    }

    func startCreating() {
        categoryName = ""
        selectedHex = nil
        selectionState = .creating
    }

    func startEditing(category: Category) {
        categoryName = category.name
        selectedHex = category.color
        selectedCategoryId = category.id
        selectionState = .editing
    }
    
    func events(for category: Category, from eventStore: EventStore) -> [Event] {
        eventStore.events.filter { $0.categoryID == category.id }
    }
    
    func save(in categoryManager: CategoryManager) {
        let hex = selectedHex ?? "#FFFFFF"
        switch selectionState {
        case .creating:
            let newCategory = Category(id: UUID(), name: categoryName, color: hex)
            categoryManager.addCategory(newCategory)
        case .editing:
            guard let id = selectedCategoryId else { return }
            let updated = Category(id: id, name: categoryName, color: hex)
            categoryManager.updateCategory(updated)
        case .reading:
            break
        }
        cancel()
    }

    func prepareDeletion(for category: Category, eventCount: Int) {
        self.categoryToDelete = category
        self.pendingDeleteEventCount = eventCount
        self.showDeleteAlert = true
    }

    func confirmDeletion(in manager: CategoryManager, deleteEvents: Bool) {
        guard let category = categoryToDelete else { return }
        manager.deleteCategory(id: category.id, deleteEvents: deleteEvents)
        categoryToDelete = nil
    }

    func cancel() {
        categoryName = ""
        selectedCategoryId = nil
        selectionState = .reading
    }
}
