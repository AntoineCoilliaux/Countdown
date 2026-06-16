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
    @State private var isShowingEmojiPicker = false
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
                    mediaSection
                    titleSection
                    categorySection
                    dateSection
                    repeatSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color(hex: K.Colors.appBackground) ?? .black)
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
        
        .sheet(isPresented: $isShowingEmojiPicker) {
            EmojiPickerSheet(selectedEmoji: $vm.emoji)
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
    
    // MARK: - Image & Emoji Views
    
    @ViewBuilder
    private var imageView: some View {
        if vm.isLocalImage {
            if let uiImage = vm.displayImage {
                Image(uiImage: uiImage).resizable()
            } else {
                Image(systemName: "photo").resizable()
            }
        } else if network.isConnected {
            AsyncImage(url: vm.imageName) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "photo").resizable().foregroundStyle(.secondary)
        }
    }
    
    private var emojiView : some View {
        ZStack {
            LinearGradient(
                colors: [(currentCategoryColor ?? .white).opacity(0.35), (currentCategoryColor ?? .white).opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(vm.emoji)
                .font(.system(size: 52))
        }
    }
    
    // MARK: - Sections
    private var mediaSection: some View {
        VStack(spacing: 5) {
            EventMediaView(
                displayMode: vm.displayMode,
                emoji: vm.emoji,
                categoryColor: currentCategoryColor ?? .white,
                emojiHeight: 190,
                photoHeight: 170
            ) {
                imageView
            }
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                if vm.displayMode == .emoji {
                    isShowingEmojiPicker = true
                } else {
                    isShowingImageSheet = true
                }
            }

                HStack(spacing: 8) {
                    Button { vm.displayMode = .photo } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                            Text(K.EditorView.photoPickerName)
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(vm.displayMode == .photo ? Color.white.opacity(0.15) : Color.clear)
                        .foregroundStyle(vm.displayMode == .photo ? .white : .white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(vm.displayMode == .photo ? 0.3 : 0.1), lineWidth: 1))
                    }
                    
                    Button { vm.displayMode = .emoji } label: {
                        HStack(spacing: 6) {
                            Text("😀").font(.system(size: 13))
                            Text(K.EditorView.emojiPickerName)
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(vm.displayMode == .emoji ? Color.white.opacity(0.15) : Color.clear)
                        .foregroundStyle(vm.displayMode == .emoji ? .white : .white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(vm.displayMode == .emoji ? 0.3 : 0.1), lineWidth: 1))
                    }
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    //MARK - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(K.EditorView.titleHeader)
            
            VStack(spacing: 0) {
                TextField("", text: $vm.name, prompt: Text(K.EditorView.textfieldPlaceholder)
                    .foregroundStyle(.white.opacity(0.5)))
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .tint(.white)
                .submitLabel(.done)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(.white.opacity(0.3)), alignment: .bottom)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(CardBackground(borderColor: vm.eventTitleIsTooLong ? .red : .white))
            
            if vm.eventTitleIsTooLong {
                ErrorText()
            }
        }
    }
    
    //MARK - Category
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(K.EditorView.categoryHeader)

            switch vm.selectionState {
            case .reading:
                VStack(alignment: .leading, spacing: 8) {
                    categoryPillsRow
                    Text(K.EditorView.categoryHint)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
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
                .background(CardBackground(borderColor: vm.categoryNameIsTooLong ? .red : .white))
            }

            if vm.categoryNameIsTooLong {
                ErrorText()
            }
        }
    }

    private var categoryPillsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categoryManager.categories) { category in
                    categoryPill(category)
                        .contextMenu {
                            Button {
                                vm.startEditing(category: category)
                                selectedHex = category.color
                                currentCategoryColor = Color(hex: selectedHex ?? K.Colors.appBackground)
                            } label: {
                                Label(K.Common.Buttons.editCategory, systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                vm.selectedCategoryId = category.id
                                showDeleteAlert = true
                            } label: {
                                Label(K.Common.Buttons.deleteCategory, systemImage: "trash")
                            }
                        }
                }

                Button {
                    vm.startCreating()
                    selectedHex = nil
                    currentCategoryColor = nil
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(K.Common.Buttons.addAnotherCategory)
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .overlay(
                        Capsule().strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .foregroundStyle(.white.opacity(0.25))
                    )
                }
            }
        }
    }

    private func categoryPill(_ category: Category) -> some View {
        let isSelected = vm.selectedCategoryId == category.id
        let color = Color(hex: category.color) ?? .white

        return Button {
            vm.selectedCategoryId = isSelected ? nil : category.id
        } label: {
            Text(category.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? .black : color)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? color : color.opacity(0.15))
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(color.opacity(isSelected ? 0 : 0.4), lineWidth: 1)
                )
        }
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
            .colorScheme(.dark)
            .background(CardBackground(borderColor: .white))
        }
    }
    
    //MARK - Repeat
    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(K.EditorView.repeatHeader)

            HStack(spacing: 6) {
                repeatOption(.never, label: K.EditorView.repeatNone)
                repeatOption(.weekly, label: K.EditorView.repeatWeekly)
                repeatOption(.monthly, label: K.EditorView.repeatMonthly)
                repeatOption(.yearly, label: K.EditorView.repeatYearly)
            }
        }
    }

    private func repeatOption(_ rule: RepeatRule, label: String) -> some View {
        let isSelected = vm.repeatRule == rule

        return Button {
            vm.repeatRule = rule
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
                .background(isSelected ? Color.white.opacity(0.12) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(.white.opacity(isSelected ? 0.25 : 0.1), lineWidth: 1))
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
