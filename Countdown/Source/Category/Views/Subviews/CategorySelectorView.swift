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
    let onManageCategories: () -> Void

    var showAllOption: Bool = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                if showAllOption {
                    Button {
                        selectedCategoryId = nil
                    } label: {
                        let isSelected = selectedCategoryId == nil
                        Text(K.HomeView.all)
                            .categoryButtonStyle(
                                foreground: isSelected ? Color.screenBackground : Color.textPrimary,
                                background: isSelected ? Color.textPrimary : Color.textPrimary.opacity(0.15)
                            )
                    }
                }

                ForEach(categoryManager.categories) { category in
                    categoryPill(category)
                }

                Button {
                    onManageCategories()
                } label: {
                    Label(K.Common.Category.manageCategories, systemImage: "pencil")
                        .categoryButtonStyle(
                            foreground: Color.textPrimary.opacity(0.5),
                            dashed: true
                        )
                }
            }
        }
    }

    private func categoryPill(_ category: Category) -> some View {
        let isSelected = selectedCategoryId == category.id
        let color = Color.category(hex: category.color)

        return Button {
            selectedCategoryId = isSelected ? nil : category.id
        } label: {
            Text(category.name)
                .categoryButtonStyle(
                    foreground: isSelected ? Color.onCategory : color,
                    background: isSelected ? color : color.opacity(0.15)
                )
        }
    }
}
