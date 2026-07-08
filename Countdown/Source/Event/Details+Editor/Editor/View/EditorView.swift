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
    @State private var dateExpanded = false
    @State private var reminderExpanded = false
    @State private var currentCategoryColor: Color?
    @State private var showingManageCategories = false
    @State private var isShowingReminderSheet = false
    
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
                    dateAndNotificationsSection
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
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        
        .sheet(isPresented: $isShowingImageSheet) {
            ImagePickerSheetView { url in
                Task {
                    await vm.selectRemoteImage(url)
                }
                isShowingImageSheet = false
            }
            .presentationDragIndicator(.visible)
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
        
        .onChange(of: vm.date) { _, newDate in
            if newDate <= Date() {
                vm.reminders.removeAll()
                reminderExpanded = false
            } else {
                // Retire les custom reminders postérieurs à la nouvelle date
                vm.reminders.removeAll {
                    if case .custom(let d) = $0 { return d >= newDate }
                    return false
                }
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
    
    private var emojiView: some View {
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
                    isSelected: vm.displayMode == .emoji,
                    action: { vm.displayMode = .emoji }
                ) {
                    Text("😀").font(.system(size: 13))
                    Text(K.EditorView.emojiPickerName)
                }
                .frame(maxWidth: .infinity)
                .background(selectionGradient(when: vm.displayMode == .emoji))
                
                SegmentedOptionButton(
                    isSelected: vm.displayMode == .photo,
                    action: { vm.displayMode = .photo }
                ) {
                    Image(systemName: "photo")
                    Text(K.EditorView.photoPickerName)
                }
                .frame(maxWidth: .infinity)
                .background(selectionGradient(when: vm.displayMode == .photo))

            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
    
    // MARK: - Title
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(K.EditorView.countingDownTo)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.75))
            
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
    
    // MARK: - Category
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            CategorySelectorView(
                selectedCategoryId: $vm.selectedCategoryId,
                showingManageCategories: $showingManageCategories,
                showAllOption: false
            )
        }
    }
    
    // MARK: - Schedule (Date + Remind me), matching the mockup card style
    
    private var dateAndNotificationsSection: some View {
        VStack(spacing: 0) {
            dateRow
            AppDivider()
            notifyMe
            AppDivider()
            remindMe
        }
        .background(CardBackground(borderColor: currentCategoryColor ?? .white))
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
    
    private func selectionGradient(when condition: Bool) -> LinearGradient {
        LinearGradient(
            colors: condition
                ? [(currentCategoryColor ?? .white).opacity(0.35),
                   (currentCategoryColor ?? .white).opacity(0.15)]
                : [.clear, .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    //MARK: - Subviews
    private var dateRow: some View {
        VStack(spacing: 0) {
            Button {
                dateExpanded.toggle()
                if dateExpanded { reminderExpanded = false }
            } label: {
                scheduleRow(title: K.EditorView.date, titleOpacity: 1) {
                    HStack(spacing: 6) {
                        Text(vm.formattedDate)
                            .foregroundStyle(.white)
                            .font(.system(size: 15))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                            .rotationEffect(.degrees(dateExpanded ? 180 : 0))
                    }
                }
            }
            .buttonStyle(.plain)
            
            if dateExpanded {
                AppDivider()
                DatePicker(
                    "",
                    selection: $vm.date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding(12)
            }
        }
    }
    
    private var notifyMe: some View {
        HStack {
            scheduleRow(title: K.EditorView.notifyMe, titleOpacity: 0.6) {
                Toggle("", isOn: Binding(
                    get: { vm.reminders.contains(.now) },
                    set: { enabled in
                        if enabled {
                            vm.reminders.append(.now)
                        } else {
                            vm.reminders.removeAll { $0 == .now }
                        }
                    }
                ))
                .labelsHidden()
                .tint(currentCategoryColor ?? .green)
            }
        }
        .disabled(vm.date <= Date())
        .opacity(vm.date <= Date() ? 0.35 : 1)
    }
    
    private var remindMe: some View {
        VStack(spacing: 0) {
            Button {
                guard vm.date > Date() else { return }
                reminderExpanded.toggle()
                if reminderExpanded { dateExpanded = false }
            } label: {
                scheduleRow(title: K.Common.Reminder.remindMe, titleOpacity: 0.6) {
                    HStack(spacing: 6) {
                        Image(systemName: vm.reminders.isEmpty ? "bell" : "bell.badge")
                            .font(.system(size: 11))
                            .foregroundStyle(vm.reminders.isEmpty ? .white.opacity(0.3) : currentCategoryColor ?? .white)
                        Text(vm.remindersSummary)
                            .font(.system(size: 13))
                            .foregroundStyle(vm.reminders.isEmpty ? .white.opacity(0.4) : .white.opacity(0.6))
                            .lineLimit(3)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                            .rotationEffect(.degrees(reminderExpanded ? 180 : 0))
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(vm.date <= Date())
            .opacity(vm.date <= Date() ? 0.35 : 1)
            
            if reminderExpanded {
                AppDivider()
                ReminderPickerView(eventDate: vm.date, reminders: $vm.reminders, borderColor: currentCategoryColor ?? .white)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    @ViewBuilder
    private func scheduleRow<Trailing: View>(title: String, titleOpacity: CGFloat, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(titleOpacity))
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
