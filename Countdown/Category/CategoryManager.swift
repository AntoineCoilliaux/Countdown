//
//  CategoryManager.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 25/02/2026.
//

import Combine
import Foundation

class CategoryManager: ObservableObject {
    @Published var categories: [Category] = []
    
    init() {
        self.categories = loadCategories()
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        saveCategories()
    }
    
    private func loadCategories() -> [Category] {
        guard let data = UserDefaults.standard.data(forKey: K.CategoryManager.userDefaultsKeyCategories) else {
            return []
        }
        return (try? JSONDecoder().decode([Category].self, from: data)) ?? []
    }
    
    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: K.CategoryManager.userDefaultsKeyCategories)
            UserDefaults.standard.synchronize()
        }
    }
}
