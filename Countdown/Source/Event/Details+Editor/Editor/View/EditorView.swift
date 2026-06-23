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
    @State private var showingManageCategories = false
    
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
                VStack(spacing: 25) {
                    titleSection
                    categorySection
                    mediaSection
                    dateSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(.black)
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
        
        .sheet(isPresented: $showingManageCategories) {
            ManageCategoriesView()
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
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(maxWidth: .infinity)
            } else {
                Image(systemName: "photo")
                    .resizable()
            }
        } else if network.isConnected {
            AsyncImage(url: vm.imageName) { image in
                image
                    .resizable()
                    .frame(maxWidth: .infinity)
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
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
            VStack(spacing: 20) {
                
                EventMediaView(
                    displayMode: vm.displayMode,
                    emoji: vm.emoji,
                    categoryColor: currentCategoryColor ?? .white,
                    emojiHeight: 190,
                    photoHeight: 190
                ) {
                    imageView
                }
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.15), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    if vm.displayMode == .emoji {
                        isShowingEmojiPicker = true
                    } else {
                        isShowingImageSheet = true
                    }
                }
                
                HStack(spacing: 8) {
                    SegmentedOptionButton(
                        isSelected: vm.displayMode == .photo,
                        action: {
                            vm.displayMode = .photo
                        }
                    ) {
                        Image(systemName: "photo")
                        
                        Text(K.EditorView.photoPickerName)
                    }
                    .frame(maxWidth: .infinity)
                    
                    SegmentedOptionButton(
                        isSelected: vm.displayMode == .emoji,
                        action: {
                            vm.displayMode = .emoji
                        }
                    ) {
                        Text("😀")
                            .font(.system(size: 13))
                        
                        Text(K.EditorView.emojiPickerName)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
    }
    
    //MARK - Title
    private var titleSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Counting down to")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.5))
            
            TextField("", text: $vm.name, prompt: Text(K.EditorView.textfieldPlaceholder)
                .foregroundStyle(.white.opacity(0.5)))
            .textFieldStyle(.plain)
            .font(.system(size: 30))
            .foregroundStyle(.white)
            .tint(.white)
            .submitLabel(.done)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(.white.opacity(0.3)), alignment: .bottom)
            .padding(.vertical, 14)
            
            if vm.eventTitleIsTooLong {
                ErrorText()
                    .padding(.horizontal, 16)

            }
        }
        .background(CardBackground(borderColor: vm.eventTitleIsTooLong ? .red : .clear))
    }
    
    //MARK - Category
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            CategorySelectorView(
                selectedCategoryId: $vm.selectedCategoryId,
                showingManageCategories: $showingManageCategories,
                showAllOption: false
            )
        }
    }
    
    //MARK - Date
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
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
}
