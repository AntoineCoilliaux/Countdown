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
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingImageSheet = false
    @State private var isShowingNewCategoryForm = false
    @State private var isShowingEditCategoryForm = false
    @State private var selectedHex: String? = nil
    @State private var shouldShowAddCategoryButton = true
    @State private var shouldShowEditCategoryButton = true
    
    private let categoryColors: [(name: String, hex: String)] = [
        ("Red",    "#FF453A"),
        ("Orange", "#FF9F0A"),
        ("Yellow", "#FFD60A"),
        ("Green",  "#30D158"),
        ("Teal",   "#5AC8FA"),
        ("Blue",   "#0A84FF"),
        ("Purple", "#BF5AF2"),
        ("Gray",   "#8E8E93"),
        ("Brown",  "#A2845E"),
        ("Black",  "#000000")
    ]
    
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
        
        .sheet(isPresented: $isShowingImageSheet) {
            ImagePickerSheetView { url in
                Task { await vm.selectRemoteImage(url) }
                isShowingImageSheet = false
            }
        }
        .alert(K.EditorView.saveErrorTitle, isPresented: $vm.showSaveError) {
            Button(K.EditorView.saveErrorOKButton, role: .cancel) { }
        } message: {
            Text(K.EditorView.saveErrorDescription)
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
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
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
        }
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
                Picker(K.EditorView.categoryPicker, selection: $vm.selectedCategoryId) {
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
                
                if vm.selectedCategoryId != nil && shouldShowEditCategoryButton {
                    Button {
                        showEditCategoryForm()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text(K.EditorView.editCategory)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
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
            }
            
            if isShowingNewCategoryForm || isShowingEditCategoryForm {
                
                TextField(K.EditorView.newCategoryPlaceholder, text: $vm.newCategoryName)
                if !vm.newCategoryName.isEmpty {
                    ColorRow(categoryColors: categoryColors, selectedHex: $selectedHex) { hex in
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
        }
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
        }
    }
    
    // MARK: - Helpers new category
    
    private func showNewCategoryForm() {
        vm.resetNewCategoryName()
        shouldShowAddCategoryButton = false
        shouldShowEditCategoryButton = false
        selectedHex = nil
        withAnimation {
            isShowingNewCategoryForm = true
        }
    }
    
    private func hideNewCategoryForm() {
        shouldShowAddCategoryButton = true
        shouldShowEditCategoryButton = true
        selectedHex = nil
        withAnimation {
            isShowingNewCategoryForm = false
        }
    }
    
    private func trySaveNewCategory() {
        guard vm.canSaveCategory, selectedHex != nil else { return }
        vm.colour = selectedHex
        _ = vm.createCategory(in: categoryManager)
        hideNewCategoryForm()
    }
    
    // MARK: - Helpers update category

    private func showEditCategoryForm() {
        shouldShowAddCategoryButton = false
        shouldShowEditCategoryButton = false
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
        shouldShowEditCategoryButton = true
        selectedHex = nil
        withAnimation {
            isShowingEditCategoryForm = false
        }
    }
    
    private func tryUpdateCategory() {
        guard vm.canSaveCategory, selectedHex != nil else { return }
        vm.colour = selectedHex
        vm.updateCategory(in: categoryManager)
        hideEditCategoryForm()
    }
}
