//
//  AddAnEventView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct EditorView: View {
    @StateObject var vm: EditorViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var isShowingImageSheet = false
    @State private var isShowingNewCategorySheet = false
    
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
                Text(vm.name.isEmpty ? K.EditorView.navigationTitle : vm.name)
                    .fontWeight(.bold)
                    .padding(5)
                Spacer()
                Form {
                    titleSection
                    categorySection
                    datePickerSection
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(K.EditorView.doneButton) {
                        if vm.canSave {
                            if let event = try? vm.save() {
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
            ImagePickerSheetView(
                onGallerySelect: { url in
                    vm.imageName = url
                    isShowingImageSheet = false
                },
                onPhotosSelect: { url in
                    vm.imageName = url
                    isShowingImageSheet = false
                }
            )
            .presentationDetents([.medium, .large])
        }
        .alert(
            "New Category",
            isPresented: $isShowingNewCategorySheet
        ) {
            newCategoryActions
        }
    }
    
    //MARK: - Alert
    
    private var newCategoryActions: some View {
        Group {
            TextField("e.g. Birthdays", text: $vm.newCategoryName)
            Button("Save") {
                _ = vm.createCategory(in: categoryManager)
            }
            .disabled(!vm.canSaveCategory)

            Button("Cancel", role: .cancel) {
                vm.resetNewCategoryName()
            }
        }
    }
    
//MARK: - Image View
    
    @ViewBuilder
    private var imageView: some View {
        if vm.isLocalImage {
            if let uiImage = vm.displayImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: K.EditorView.photo)
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
        Section {
            HStack(alignment: .top) {
                imageView
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
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
                    vm.resetNewCategoryName()  // ✅
                    isShowingNewCategorySheet = true
                } label: {
                    HStack {
                        Image(systemName: K.EditorView.plusCircleFillSymbol)
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
                                .fill(.yellow)
                                .frame(width: 12, height: 12)
                            Text(category.name)
                        }
                        .tag(category.id as UUID?)
                    }
                }
                
                Button {
                    vm.resetNewCategoryName()  // ✅
                    isShowingNewCategorySheet = true
                } label: {
                    HStack {
                        Image(systemName: K.EditorView.plusCircleSymbol)
                        Text(K.EditorView.addAnotherCategory)
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
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
}

//#Preview {
//    AddAnEventView(, onSave)
//}

