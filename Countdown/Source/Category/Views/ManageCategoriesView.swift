//
//  ManageCategoryView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 05/03/2026.
//

import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var eventStore: EventStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var categoryIndexPendingDeletion: IndexSet?
    @State private var showDeleteAlert = false
    @State private var categoryToEdit: Category?
    @State private var editedName: String = ""
    @State private var showEditAlert = false
    @State private var pendingDeleteEventCount: Int = 0
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categoryManager.categories) { category in
                    DisclosureGroup {
                        ForEach(eventsForCategory(category)) { event in
                            CategoryEventRow(event: event)
                                .padding(.leading, 8)
                                .allowsHitTesting(false)
                                .deleteDisabled(true)
                        }
                        
                        Divider()
                        
                        HStack {
                            Button {
                                categoryToEdit = category
                                editedName = category.name
                                showEditAlert = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.borderless)

                            
                            Spacer()
                            
                            Button {
                                categoryIndexPendingDeletion = IndexSet(
                                    [categoryManager.categories.firstIndex(where: { $0.id == category.id })!]
                                )
                                pendingDeleteEventCount = eventsForCategory(category).count
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.leading, 8)
                        .padding(.top, 4)
                        
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: category.color) ?? .gray)
                                .frame(width: 10, height: 10)
                            Text(category.name)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: K.Colors.appBackground) ?? .black)
            .colorScheme(.dark)
            .navigationTitle(K.ManageCategoriesView.manageCategoriesTitle)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(K.Common.Buttons.done) {
                        dismiss()
                    }
                }
            }
            
            .onChange(of: categoryManager.categories.count) { oldValue, newValue in
                if newValue == 0 {
                    dismiss()
                }
            }
            .alert(K.Common.Category.deleteTitle, isPresented: $showDeleteAlert) {
                
                if pendingDeleteEventCount != 0 {
                    
                    Button(K.Common.Category.deleteOnly, role: .destructive) {
                        handleDelete(deleteEvents: false)
                    }
                    Button(K.Common.Category.deleteWithEvents(count: pendingDeleteEventCount), role: .destructive) {
                        handleDelete(deleteEvents: true)
                    }
                } else {
                    Button(K.Common.Category.deleteButton, role: .destructive) {
                        handleDelete(deleteEvents: false)
                    }
                }
                
                Button(K.Common.Buttons.cancel, role: .cancel) {
                }
            } message: {
                if pendingDeleteEventCount != 0 {
                    Text(K.Common.Category.deleteWithEventsMessage)
                } else {
                    Text(K.Common.Category.deleteWithoutEventsMessage)
                }
            }
            
            .alert(K.ManageCategoriesView.alertRenameCategory, isPresented: $showEditAlert) {
                TextField(K.Common.Category.namePlaceholder, text: $editedName)
                
                Button(K.Common.Buttons.save) {
                    if let category = categoryToEdit {
                        categoryManager.renameCategory(id: category.id, newName: editedName)
                    }
                }
                
                Button(K.Common.Buttons.cancel, role: .cancel) { }
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
    
    private func eventCount(for indexSet: IndexSet) -> Int {
        guard let index = indexSet.first else { return 0 }
        let category = categoryManager.categories[index]
        return eventStore.events.filter { $0.categoryID == category.id }.count
    }
    
    private func eventsForCategory(_ category: Category) -> [Event] {
        eventStore.events.filter { $0.categoryID == category.id }
    }
    
}

//#Preview {
//    ManageCategoriesView()
//}

