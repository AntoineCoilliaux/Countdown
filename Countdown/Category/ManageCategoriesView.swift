//
//  ManageCategoryView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 05/03/2026.
//

import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @Environment(\.dismiss) private var dismiss
    @State private var categoryIndexPendingDeletion: IndexSet? = nil
    @State private var showDeleteAlert = false
    @State private var categoryToEdit: Category?
    @State private var editedName: String = ""
    @State private var showEditAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categoryManager.categories) { category in
                    HStack {
                        Circle().fill(.yellow).frame(width: 10, height: 10)
                        Text(category.name)
                    }
                    .onTapGesture {
                        categoryToEdit = category
                        editedName = category.name
                        showEditAlert = true
                    }
                }
                .onDelete { indexSet in
                    categoryIndexPendingDeletion = indexSet
                    showDeleteAlert = true
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete category?", isPresented: $showDeleteAlert) {
                Button("Delete category only", role: .destructive) {
                    handleDelete(deleteEvents: false)
                }
                Button("Delete category and events", role: .destructive) {
                    handleDelete(deleteEvents: true)
                }
                Button("Cancel", role: .cancel) {
                    categoryIndexPendingDeletion = nil
                }
            } message: {
                Text("Do you want to delete only the category (events will move to All) or delete the category and all its events?")
            }
            
            .alert("Rename category", isPresented: $showEditAlert) {
                TextField("Category name", text: $editedName)

                Button("Save") {
                    if let category = categoryToEdit {
                        categoryManager.renameCategory(id: category.id, newName: editedName)
                    }
                }

                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func handleDelete(deleteEvents: Bool) {
        guard let indexSet = categoryIndexPendingDeletion else { return }
        
        for index in indexSet {
            let category = categoryManager.categories[index]
            categoryManager.deleteCategory(id: category.id, deleteEvents: deleteEvents)
        }
        
        categoryIndexPendingDeletion = nil
    }
}

//#Preview {
//    ManageCategoriesView()
//}
