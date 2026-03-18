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
            .navigationTitle(K.ManageCategoriesView.manageCategoriesTitle)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(K.ManageCategoriesView.doneButton) {
                        dismiss()
                    }
                }
            }
            .alert(K.ManageCategoriesView.alertDeleteCategory, isPresented: $showDeleteAlert) {
                Button(K.ManageCategoriesView.alertDeleteCategoryOnly, role: .destructive) {
                    handleDelete(deleteEvents: false)
                }
                Button(K.ManageCategoriesView.alertDeleteCategoryAndEvents, role: .destructive) {
                    handleDelete(deleteEvents: true)
                }
                Button(K.ManageCategoriesView.alertDeleteCategoryCancelButton, role: .cancel) {
                    categoryIndexPendingDeletion = nil
                }
            } message: {
                Text(K.ManageCategoriesView.alertMessage)
            }
            
            .alert(K.ManageCategoriesView.alertRenameCategory, isPresented: $showEditAlert) {
                TextField(K.ManageCategoriesView.alertRenameCategoryNameText, text: $editedName)
                
                Button(K.ManageCategoriesView.alertRenameCategorySaveButton) {
                    if let category = categoryToEdit {
                        categoryManager.renameCategory(id: category.id, newName: editedName)
                    }
                }
                
                Button(K.ManageCategoriesView.alertRenameCategoryCancelButton, role: .cancel) { }
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
