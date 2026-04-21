//
//  CategoryFormView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 14/04/2026.
//

import SwiftUI

struct CategoryFormView: View {
    @Binding var categoryName: String
    @Binding var selectedHex: String?
    let categoryNameIsValid: Bool
    let categoryNameIsTooLong: Bool
    let onCancel: () -> Void
    let onSave: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TextField(K.Common.Category.namePlaceholder, text: $categoryName)
                .foregroundStyle(.white)
                .paddingStyle()

            AppDivider()
            ColorRow(selectedHex: $selectedHex)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            AppDivider()
            HStack {
                Button(K.Common.Buttons.cancel, role: .cancel) {
                    onCancel()
                }
                .foregroundStyle(.red)
                .paddingStyle()

                if categoryNameIsValid && selectedHex != nil {
                    AppDivider()
                    Button {
                        onSave(selectedHex ?? "")
                    } label: {
                        Text(K.Common.Buttons.save)
                            .foregroundStyle(.blue)
                            .paddingStyle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

//#Preview {
//    CategoryFormView()
//}
