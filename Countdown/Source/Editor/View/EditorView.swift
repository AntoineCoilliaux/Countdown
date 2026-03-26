//
//  EditorView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct EditorView: View {
    @StateObject var vm: EditorViewModel
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var eventStore: EventStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingImageSheet = false
    
    @State private var isShowingNewCategoryForm = false
    @State private var isShowingEditCategoryForm = false
    
    @State private var selectedHex: String?
    @State private var shouldShowAddCategoryButton = true
    @State private var shouldShowEditDeleteCategoryButton = true
    @State private var showDeleteAlert = false
    
    @State private var categoryColor: Color?
    
    private var selectedCategoryEventCount: Int {
        guard let id = vm.selectedCategoryId else { return 0 }
        return eventStore.events.filter { $0.categoryID == id }.count
    }
    
    let onSave: (Event) -> Void
    
    init(onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EditorViewModel(mode: .add))
        self.onSave = onSave
    }
    
    init(event: Event, onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EditorViewModel(mode: .edit(existing: event)))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    titleSection
                    categorySection
                    datePickerSection
                }
                .scrollContentBackground(.hidden)
                .background(Color(hex: K.Colors.appBackground) ?? .black)
                .colorScheme(.dark)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(K.EditorView.doneButton) {
                        Task {
                            if let event = await vm.save() {
                                onSave(event)
                                dismiss()
                            }
                        }
                    }
                    .disabled(!vm.canSave)
                }
            }
        }
        .toolbarBackground(Color(hex: K.Colors.appBackground) ?? .black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        
        .sheet(isPresented: $isShowingImageSheet) {
            ImagePickerSheetView { url in
                Task {
                    await vm.selectRemoteImage(url)
                }
                isShowingImageSheet = false
            }
        }
        
        .alert(K.EditorView.saveErrorTitle, isPresented: $vm.showSaveError) {
            Button(K.EditorView.saveErrorOKButton, role: .cancel) { }
        } message: {
            Text(K.EditorView.saveErrorDescription)
        }
        
        .alert(K.EditorView.alertDeleteCategory, isPresented: $showDeleteAlert) {
            
            if selectedCategoryEventCount != 0 {
                
                Button(K.EditorView.alertDeleteCategoryOnly, role: .destructive) {
                    handleDelete(deleteEvents: false)
                }
                Button(K.EditorView.alertDeleteCategoryAndEvents(count: selectedCategoryEventCount), role: .destructive) {
                    handleDelete(deleteEvents: true)
                }
            } else {
                Button(K.EditorView.alertDelete, role: .destructive) {
                    handleDelete(deleteEvents: false)
                }
            }
            
            Button(K.EditorView.alertDeleteCategoryCancelButton, role: .cancel) {
            }
        } message: {
            if selectedCategoryEventCount != 0 {
                Text(K.EditorView.alertDeleteCategoryWithEventsMessage)
            } else {
                Text(K.EditorView.alertDeleteCategoryWithoutEventsMessage)
            }
        }
        
        .onAppear {
            guard let id = vm.selectedCategoryId,
                  let category = categoryManager.categories.first(where: { $0.id == id }),
                  let hex = category.colour else { return }
            categoryColor = Color(hex: hex)
        }
        
        .onChange(of: vm.selectedCategoryId) { _, newId in
            guard let id = newId,
                  let category = categoryManager.categories.first(where: { $0.id == id }),
                  let hex = category.colour else {
                categoryColor = nil
                return
            }
            categoryColor = Color(hex: hex)
        }
    }
    
    // MARK: - Image View
    
    @ViewBuilder
    private var imageView: some View {
        if vm.isLocalImage {
            if let uiImage = vm.displayImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
            }
        } else {
            AsyncImage(url: vm.imageName) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        }
    }
    
    // MARK: - Form sections
    
    private var titleSection: some View {
        Section {
            HStack(alignment: .top) {
                imageView
                    .frame(width: 62, height: 47)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 1))
                    .padding(.horizontal, 12)
                    .onTapGesture {
                        isShowingImageSheet = true
                    }
                
                VStack(alignment: .center) {
                    Spacer()
                    TextField(K.EditorView.textfieldPlaceholder, text: $vm.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } header: {
            Text(K.EditorView.titleHeader)
                .foregroundStyle(.white)
        }
        .listRowBackground(categoryColor ?? Color(hex: K.Colors.editorBackground) ?? .black)
    }
    
    private var categorySection: some View {
        Section {
            if categoryManager.categories.isEmpty {
                Button {
                    showNewCategoryForm()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text(K.EditorView.createACategory)
                    }
                }
            } else {
                Picker(K.EditorView.categoryPicker, selection: isShowingNewCategoryForm ? .constant(nil) : $vm.selectedCategoryId) {
                    Text(K.EditorView.none)
                        .tag(nil as UUID?)
                    
                    ForEach(categoryManager.categories) { category in
                        HStack {
                            Circle()
                                .fill(Color(hex: category.colour ?? "") ?? .yellow)
                                .frame(width: 12, height: 12)
                            Text(category.name)
                        }
                        .tag(category.id as UUID?)
                    }
                }
                .disabled(isShowingEditCategoryForm)
                
                if shouldShowAddCategoryButton {
                    Button {
                        showNewCategoryForm()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text(K.EditorView.addAnotherCategory)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                
                if vm.selectedCategoryId != nil && shouldShowEditDeleteCategoryButton {
                    Button {
                        showEditCategoryForm()
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text(K.EditorView.editCategory)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    Button {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text(K.EditorView.deleteCategory)
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                }
 
            }
            
            if isShowingNewCategoryForm || isShowingEditCategoryForm {
                
                TextField(K.EditorView.newCategoryPlaceholder, text: $vm.newCategoryName)
                if vm.canSaveCategory {
                    ColorRow(selectedHex: $selectedHex) { hex in
                        if vm.canSaveCategory {
                            vm.colour = hex
                            if isShowingEditCategoryForm {
                                tryUpdateCategory()
                            } else {
                                trySaveNewCategory()
                            }
                        }
                    }
                }
                
                Button(K.EditorView.newCategoryCancelButton, role: .cancel) {
                    vm.resetNewCategoryName()
                    
                    if isShowingNewCategoryForm {
                        hideNewCategoryForm()
                    } else if isShowingEditCategoryForm {
                        hideEditCategoryForm()
                    }
                }
            }
            
        } header: {
            Text(K.EditorView.categoryHeader)
                .foregroundStyle(.white)
        }
        .listRowBackground(Color(hex: K.Colors.editorBackground) ?? .black)
    }
    
    private var datePickerSection: some View {
        Section {
            DatePicker(
                "",
                selection: $vm.date,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
        } header: {
            Text(K.EditorView.dateHeader)
                .foregroundStyle(.white)
        }
        .listRowBackground(Color(hex: K.Colors.editorBackground) ?? .black)
    }
    
    // MARK: - Helpers new category
    
    private func showNewCategoryForm() {
        vm.resetNewCategoryName()
        shouldShowAddCategoryButton = false
        shouldShowEditDeleteCategoryButton = false
        selectedHex = nil
        withAnimation {
            isShowingNewCategoryForm = true
        }
    }
    
    private func hideNewCategoryForm() {
        shouldShowAddCategoryButton = true
        shouldShowEditDeleteCategoryButton = true
        selectedHex = nil
        withAnimation {
            isShowingNewCategoryForm = false
        }
    }
    
    private func trySaveNewCategory() {
        guard vm.canSaveCategory, selectedHex != nil else { return }
        vm.colour = selectedHex
        _ = vm.createCategory(in: categoryManager)
        categoryColor = Color(hex: selectedHex ?? "")
        hideNewCategoryForm()
    }
    
    // MARK: - Helpers update category

    private func showEditCategoryForm() {
        shouldShowAddCategoryButton = false
        shouldShowEditDeleteCategoryButton = false
        guard let id = vm.selectedCategoryId,
              let category = categoryManager.categories.first(where: { $0.id == id }) else { return }
        
        vm.newCategoryName = category.name
        selectedHex = category.colour
        withAnimation {
            isShowingEditCategoryForm = true
        }
    }
    
    private func hideEditCategoryForm() {
        shouldShowAddCategoryButton = true
        shouldShowEditDeleteCategoryButton = true
        selectedHex = nil
        withAnimation {
            isShowingEditCategoryForm = false
        }
    }
    
    private func tryUpdateCategory() {
        guard vm.canSaveCategory, selectedHex != nil else { return }
        vm.colour = selectedHex
        vm.updateCategory(in: categoryManager)
        categoryColor = Color(hex: selectedHex ?? "")
        hideEditCategoryForm()
    }
    
    //MARK: - Delete category
    
    private func handleDelete(deleteEvents: Bool) {
        guard let id = vm.selectedCategoryId else { return }
        categoryManager.deleteCategory(id: id, deleteEvents: deleteEvents)
        vm.selectedCategoryId = nil
        showDeleteAlert = false
    }
}
