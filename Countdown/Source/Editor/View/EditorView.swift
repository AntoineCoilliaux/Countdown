//
//  EditorView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct EditorView: View {
    @StateObject var vm: EditorViewModel
    @StateObject private var network = NetworkMonitor()

    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var eventStore: EventStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingImageSheet = false
    @State private var selectedHex: String?
    @State private var showDeleteAlert = false
    @State private var isExpanded = false
    @State private var currentCategoryColor: Color?
    
    
    private var selectedCategoryEventCount: Int {
        guard let id = vm.selectedCategoryId else { return 0 }
        return eventStore.events.filter { $0.categoryID == id }.count
    }
    
    let onSave: (Event) -> Void
    
    init(onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EditorViewModel(mode: .add))
        self.onSave = onSave
    }
    
    init(event: Event, initialCategoryColor: Color?, onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EditorViewModel(mode: .edit(existing: event)))
        _currentCategoryColor = State(initialValue: initialCategoryColor)
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
                    .disabled(!vm.canSave || vm.selectionState != .reading)
                }
            }
        }
        .toolbarBackground(
            currentCategoryColor ?? Color(hex: K.Colors.appBackground) ?? .black, for: .navigationBar
        )
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
            Button(K.Common.Buttons.ok, role: .cancel) { }
        } message: {
            Text(K.EditorView.saveErrorDescription)
        }
        
        .alert(K.Common.Category.deleteAlertTitle, isPresented: $showDeleteAlert) {
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
            Button(K.Common.Buttons.cancel, role: .cancel) {}
            
        } message: {
            if selectedCategoryEventCount != 0 {
                Text(K.Common.Category.deleteWithEventsMessage)
            } else {
                Text(K.Common.Category.deleteWithoutEventsMessage)
            }
        }
        
        .onAppear {
            refreshCurrentColor()
        }
        .onChange(of: vm.selectedCategoryId) { _, _ in
            refreshCurrentColor()
        }
        
        .onChange(of: selectedHex ?? K.Colors.appBackground) { _, newHex in
            if vm.selectionState == .creating || vm.selectionState == .editing {
                currentCategoryColor = Color(hex: newHex)
            }
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
        } else if network.isConnected {
            AsyncImage(url: vm.imageName) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Sections
    //MARK - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(K.EditorView.titleHeader)
            
            HStack(alignment: .center, spacing: 12) {
                imageView
                    .frame(width: 62, height: 47)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4), lineWidth: 1))
                    .onTapGesture {
                        isShowingImageSheet = true
                    }
                VStack {
                    TextField(K.EditorView.textfieldPlaceholder, text: $vm.name)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundStyle(.white.opacity(0.3)), alignment: .bottom)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(CardBackground(borderColor: (vm.eventTitleIsTooLong ? .red : .white)))
            
            if vm.eventTitleIsTooLong {
                ErrorText()
            }
            
        }
    }
    
    //MARK - Category
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(K.EditorView.categoryHeader)
            
            VStack(spacing: 0) {
                switch vm.selectionState {
                case .reading:
                    if categoryManager.categories.isEmpty {
                        MakeCategoryButton(imageName: "plus.circle.fill", text: K.Common.Buttons.createFirstCategory, color: .blue) {
                            vm.startCreating()
                        }
                    } else {
                        categoryPicker
                        
                        AppDivider()
                        MakeCategoryButton(imageName: "plus.circle", text: K.Common.Buttons.addAnotherCategory, color: .blue) {
                            vm.startCreating()
                            selectedHex = nil
                            currentCategoryColor = nil
                        }
                        
                        if let id = vm.selectedCategoryId,
                           let category = categoryManager.categories.first(where: { $0.id == id }) {
                            AppDivider()
                            MakeCategoryButton(imageName: "pencil", text: K.Common.Buttons.editCategory, color: .blue) {
                                vm.startEditing(category: category)
                                selectedHex = category.color
                                currentCategoryColor = Color(hex: selectedHex ?? K.Colors.appBackground)
                            }
                            
                            AppDivider()
                            MakeCategoryButton(imageName: "trash", text: K.Common.Buttons.deleteCategory, color: .red) {
                                showDeleteAlert = true
                            }
                        }
                    }
                    
                case .creating, .editing:
                    CategoryFormView(
                        categoryName: $vm.categoryName,
                        selectedHex: $selectedHex,
                        categoryNameIsValid: vm.categoryNameIsValid,
                        categoryNameIsTooLong: vm.categoryNameIsTooLong,
                        onCancel: {
                            vm.cancelCategoryAction()
                            refreshCurrentColor()
                        },
                        onSave: { hex in
                            vm.saveCategory(in: categoryManager, hex: hex)
                            currentCategoryColor = Color(hex: hex)
                        }
                    )
                }
            }
            .background(CardBackground(borderColor: vm.categoryNameIsTooLong ? .red : .white))
            
            if vm.categoryNameIsTooLong {
                ErrorText()
            }
        }
    }
    
    private var categoryPicker: some View {
        Picker("", selection: vm.selectionState == .creating ? .constant(nil) : $vm.selectedCategoryId) {
            Text(K.EditorView.none)
                .tag(nil as UUID?)
            ForEach(categoryManager.categories) { category in
                HStack {
                    Circle()
                        .fill(Color(hex: category.color) ?? .white)
                        .frame(width: 12, height: 12)
                    Text(category.name)
                }
                .tag(category.id as UUID?)
            }
        }
        .tint(.white)
        .disabled(vm.selectionState != .reading)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    //MARK - Date
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(K.EditorView.dateHeader)
            
            VStack(spacing: 0) {
                
                Button {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(vm.formattedDate)
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
                    AppDivider()
                    DatePicker(
                        "",
                        selection: $vm.date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding(12)
                }
            }
            .background(CardBackground(borderColor: .white))
        }
    }
    
    // MARK: - Helpers
    
    private func handleDelete(deleteEvents: Bool) {
        guard let id = vm.selectedCategoryId else { return }
        categoryManager.deleteCategory(id: id, deleteEvents: deleteEvents)
        vm.selectedCategoryId = nil
        showDeleteAlert = false
    }
    
    private func refreshCurrentColor() {
        if let id = vm.selectedCategoryId,
           let category = categoryManager.categories.first(where: { $0.id == id }) {
            currentCategoryColor = Color(hex: category.color)
        } else {
            currentCategoryColor = nil
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(.white.opacity(0.5))
    }
}
