//
//  ManageCategoriesView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 05/03/2026.
//

import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var eventStore: EventStore
    @StateObject var vm = ManageCategoriesViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    private var sortedCategories: [Category] {
        categoryManager.categories.sorted {
            vm.events(for: $0, from: eventStore).count >
            vm.events(for: $1, from: eventStore).count
        }
    }
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color(hex: K.Colors.appBackground)
                        .ignoresSafeArea()
                    
                    Group {
                        if categoryManager.categories.isEmpty {
                            emptyState
                        } else {
                            categoryList
                        }
                    }
                    .blur(radius: vm.selectionState != .reading ? 4 : 0)
                    .disabled(vm.selectionState != .reading)
                    
                    if vm.selectionState != .reading {
                        overlayBackground
                        
                        categoryFormSection
                    }
                }
                .navigationTitle(K.ManageCategoriesView.manageCategoriesTitle)
                .navigationBarTitleDisplayMode(.large)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .preferredColorScheme(.dark)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(K.Common.Buttons.done) { dismiss() }
                            .disabled(vm.selectionState != .reading)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.selectionState)
                .alert(K.Common.Category.deleteAlertTitle, isPresented: $vm.showDeleteAlert) {
                    deleteAlertButtons
                } message: {
                    deleteAlertMessage
                }
            }
        }
    
    // MARK: - Sections
    
    private var categoryList: some View {
        ScrollView {
            VStack(spacing: 12) {
                
                ForEach(sortedCategories) { category in
                    VStack(spacing: 0) {
                        
                        DisclosureGroup {
                            categoryDetailRows(for: category)
                                .padding(.top, 12)
                        } label: {
                            categoryHeader(for: category)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#1c1c2e") ?? .black.opacity(0.8))
                            .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(hex: category.color) ?? .gray.opacity(0.5), lineWidth: 3)
                        ))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                    addCategoryButtonView
                
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }

    private func categoryHeader(for category: Category) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: category.color) ?? .gray)
                .frame(width: 20, height: 20)
            
            Text(category.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            let count = vm.events(for: category, from: eventStore).count
            Text("\(count) event\(count <= 1 ? "" : "s")")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
        }
        .tint(.white.opacity(0.3))
    }

    private var addCategoryButtonView: some View {
        Button {
            vm.startCreating()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18, weight: .medium))
                Text(K.Common.Buttons.addAnotherCategory)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.25), lineWidth: 0.5)
                    )
            }
        }
    }
    
    private var overlayBackground: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture { vm.cancel() }
            .transition(.opacity)
            .zIndex(1)
    }

    private var formBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(hex: K.Colors.appBackground) ?? .gray)
            .shadow(radius: 20)
    }

    @ViewBuilder
    private func categoryDetailRows(for category: Category) -> some View {
        let categoryEvents = vm.events(for: category, from: eventStore)
        if categoryEvents.isEmpty {
            Text(K.HomeView.noEventsYet)
                .font(.title)
                .italic()
                .foregroundStyle(.secondary)
        } else {
            ForEach(categoryEvents) { event in
                CategoryEventRow(event: event)
                    .padding(.leading, 8)
            }
        }
        
        Divider()
        
        HStack {
            Button(role: .destructive) {
                vm.prepareDeletion(for: category, eventCount: categoryEvents.count)
            } label: {
                Label(K.Common.Buttons.deleteCategory, systemImage: "trash")
            }
            .buttonStyle(.borderless)
            
            Spacer()
            Divider()
            Spacer()
            
            Button {
                vm.startEditing(category: category)
                vm.selectedHex = category.color
            } label: {
                Label(K.Common.Buttons.editCategory, systemImage: "pencil")
            }
            .buttonStyle(.borderless)
        }
    }
    
    private var categoryFormSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(vm.selectionState == .creating ? K.ManageCategoriesView.newCategory : K.ManageCategoriesView.editCategory)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            CategoryFormView(
                categoryName: $vm.categoryName,
                selectedHex: $vm.selectedHex,
                categoryNameIsValid: vm.categoryNameIsValid,
                categoryNameIsTooLong: vm.categoryNameIsTooLong,
                onCancel: { vm.cancel() },
                onSave: { hex in
                    vm.save(in: categoryManager)
                }
            )
            
            if vm.categoryNameIsTooLong {
                ErrorText()
            }
        }
        .padding(10)
            .background(CardBackground(borderColor: vm.categoryNameIsTooLong ? .red : .white))
            .background(formBackground)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 30)
            .padding(.bottom, 80)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
            .zIndex(2)
    }
    
    // MARK: - Helpers & Alert UI
    
    @ViewBuilder
    private var deleteAlertButtons: some View {
        if vm.pendingDeleteEventCount != 0 {
            Button(K.Common.Category.deleteOnly, role: .destructive) {
                vm.confirmDeletion(in: categoryManager, deleteEvents: false)
            }
            Button(K.Common.Category.deleteWithEvents(count: vm.pendingDeleteEventCount), role: .destructive) { vm.confirmDeletion(in: categoryManager, deleteEvents: true)
            }
        } else {
            Button(K.Common.Category.deleteButton, role: .destructive) {
                vm.confirmDeletion(in: categoryManager, deleteEvents: false)
            }
        }
        Button(K.Common.Buttons.cancel, role: .cancel) {}
    }
    
    private var deleteAlertMessage: Text {
        Text(vm.pendingDeleteEventCount != 0 ? K.Common.Category.deleteWithEventsMessage : K.Common.Category.deleteWithoutEventsMessage)
    }
    
    private var emptyState: some View {
        
        VStack(alignment: .leading, spacing: 25) {
            VStack(spacing: 10) {
                Image(systemName: "tag.slash")
                    .foregroundStyle(.white)
                    .font(.system(size: 40))
                
                Text(K.ManageCategoriesView.noCategories)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Button {
                vm.startCreating()
                vm.selectedHex = nil
            } label: {
                Text(K.Common.Buttons.createFirstCategory)
                    .foregroundStyle(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }
        }
    }
}

//#Preview {
//    ManageCategoriesView()
//}

