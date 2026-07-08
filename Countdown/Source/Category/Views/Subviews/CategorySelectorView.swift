//
//  CategorySelectorView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/06/2026.
//

import SwiftUI

struct CategorySelectorView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    
    @Binding var selectedCategoryId: UUID?
    @Binding var showingManageCategories: Bool
    
    var showAllOption: Bool = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                
                if showAllOption {
                    Button {
                        selectedCategoryId = nil
                    } label: {
                        Text(K.HomeView.all)
                            .categoryButtonStyle(
                                foreground: selectedCategoryId == nil ? .black : .white,
                                background: selectedCategoryId == nil ? .white : .white.opacity(0.15)
                            )
                    }
                }
                
                ForEach(categoryManager.categories) { category in
                    categoryPill(category)
                }
                
                Button {
                    showingManageCategories = true
                } label: {
                    Label(K.Common.Category.manageCategories, systemImage: "pencil")
                        .categoryButtonStyle(
                            foreground: .white.opacity(0.5),
                            dashed: true
                        )
                }
            }
        }
    }

    private func categoryPill(_ category: Category) -> some View {
        let isSelected = selectedCategoryId == category.id
        let color = Color(hex: category.color) ?? .white

        return Button {
            selectedCategoryId = isSelected ? nil : category.id
        } label: {
            Text(category.name)
                .categoryButtonStyle(
                    foreground: isSelected ? .black : color,
                    background: isSelected ? color : color.opacity(0.15)
                )
        }
    }
}

//#Preview {
//    CategorySelectorView(showingManageCategories: false)
//}
