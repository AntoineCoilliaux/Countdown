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
    
    @State private var shouldShowCreateFirstCategoryButton = true
    @State private var shouldShowAddCategoryButton = true
    @State private var shouldShowEditDeleteCategoryButton = true
    @State private var shouldShowPicker = true

    @State private var showDeleteAlert = false
    @State private var isExpanded = false

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
            ScrollView {
                VStack(spacing: 34) {
                    titleSection
                    categorySection
                    dateSection
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color(hex: K.Colors.appBackground) ?? .black)
            .colorScheme(.dark)
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
                Task { await vm.selectRemoteImage(url) }
                isShowingImageSheet = false
            }
        }

        .alert(K.EditorView.saveErrorTitle, isPresented: $vm.showSaveError) {
            Button(K.Common.Buttons.ok, role: .cancel) { }
        } message: {
            Text(K.EditorView.saveErrorDescription)
        }

        .alert(K.Common.Category.deleteTitle, isPresented: $showDeleteAlert) {
            if selectedCategoryEventCount != 0 {
                Button(K.Common.Category.deleteOnly, role: .destructive) {
                    handleDelete(deleteEvents: false)
                }
                Button(K.Common.Category.deleteWithEvents(count: selectedCategoryEventCount), role: .destructive) {
                    handleDelete(deleteEvents: true)
                }
            } else {
                Button(K.Common.Category.deleteButton, role: .destructive) {
                    handleDelete(deleteEvents: false)
                }
            }
            Button(K.Common.Buttons.cancel, role: .cancel) {
                shouldShowPicker = true
            }
        } message: {
            if selectedCategoryEventCount != 0 {
                Text(K.Common.Category.deleteWithEventsMessage)
            } else {
                Text(K.Common.Category.deleteWithoutEventsMessage)
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

    // MARK: - Sections

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(K.EditorView.titleHeader)
                .font(.caption)
                 .fontWeight(.medium)
                 .textCase(.uppercase)
                 .tracking(1.2)
                 .foregroundStyle(.white.opacity(0.5))

            HStack(alignment: .center, spacing: 12) {
                imageView
                    .frame(width: 62, height: 47)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4), lineWidth: 1))
                    .onTapGesture {
                        isShowingImageSheet = true
                    }

                TextField(K.EditorView.textfieldPlaceholder, text: $vm.name)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundStyle(.white.opacity(0.3)),
                        alignment: .bottom
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(CardBackground())
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(K.EditorView.categoryHeader)
                .font(.caption)
                 .fontWeight(.medium)
                 .textCase(.uppercase)
                 .tracking(1.2)
                 .foregroundStyle(.white.opacity(0.5))

            VStack(spacing: 0) {
                if categoryManager.categories.isEmpty && shouldShowCreateFirstCategoryButton {
                    makeCategoryButton(imageName: "plus.circle.fill", text: K.EditorView.createFirstCategory, color: .blue) {
                        showNewCategoryForm()
                    }
                } else {
                    if shouldShowPicker {
                        categoryPicker
                    }

                    if shouldShowAddCategoryButton {
                        Divider().background(.white.opacity(0.08))
                        makeCategoryButton(imageName: "plus.circle", text: K.EditorView.addAnotherCategory, color: .blue) {
                            showNewCategoryForm()
                        }
                    }

                    if vm.selectedCategoryId != nil && shouldShowEditDeleteCategoryButton {
                        Divider().background(.white.opacity(0.08))
                        makeCategoryButton(imageName: "pencil", text: K.EditorView.editCategory, color: .blue) {
                            showEditCategoryForm()
                        }

                        Divider().background(.white.opacity(0.08))
                        makeCategoryButton(imageName: "trash", text: K.EditorView.deleteCategory, color: .red) {
                            showDeleteAlert = true
                        }
                    }
                }

                if isShowingNewCategoryForm || isShowingEditCategoryForm {
                    Divider().background(.white.opacity(0.08))

                    TextField(K.Common.Category.namePlaceholder, text: $vm.newCategoryName)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    if vm.canSaveCategory {
                        Divider().background(.white.opacity(0.08))

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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    Divider().background(.white.opacity(0.08))

                    Button(K.Common.Buttons.cancel, role: .cancel) {
                        vm.resetNewCategoryName()
                        if isShowingNewCategoryForm {
                            hideNewCategoryForm()
                        } else if isShowingEditCategoryForm {
                            hideEditCategoryForm()
                        }
                    }
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(CardBackground())
        }
    }
    private func makeCategoryButton(imageName: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(color)
                Text(text)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var categoryPicker: some View {
        Picker("", selection: isShowingNewCategoryForm ? .constant(nil) : $vm.selectedCategoryId) {
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
        .tint(.white)
        .disabled(isShowingEditCategoryForm)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(K.EditorView.dateHeader)
                .font(.caption)
                .fontWeight(.medium)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.5))

            VStack(spacing: 0) {

                Button {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(vm.date.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut, value: isExpanded)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }

                if isExpanded {
                    Divider().background(.white.opacity(0.08))

                    DatePicker(
                        "",
                        selection: $vm.date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding(12)
                }
            }
            .background(CardBackground())
        }
    }

    // MARK: - Helpers new category

    private func showNewCategoryForm() {
        vm.resetNewCategoryName()
        shouldShowPicker = false
        shouldShowCreateFirstCategoryButton = false
        shouldShowAddCategoryButton = false
        shouldShowEditDeleteCategoryButton = false
        selectedHex = nil
        isShowingNewCategoryForm = true
    }

    private func hideNewCategoryForm() {
        shouldShowPicker = true
        shouldShowCreateFirstCategoryButton = true
        shouldShowAddCategoryButton = true
        shouldShowEditDeleteCategoryButton = true
        selectedHex = nil
        isShowingNewCategoryForm = false
    }

    private func trySaveNewCategory() {
        guard vm.canSaveCategory, selectedHex != nil else { return }
        shouldShowPicker = true
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
