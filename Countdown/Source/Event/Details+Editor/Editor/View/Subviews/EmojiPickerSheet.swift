//
//  EmojiPickerSheet.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 11/06/2026.
//

import SwiftUI

struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    private let categories = K.Emojis.categories
    
    @State private var selectedCategory = 0

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories.indices, id: \.self) { i in
                        Button {
                            selectedCategory = i
                        } label: {
                            Text(categories[i].icon)
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .background(selectedCategory == i ? Color.white.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(selectedCategory == i ? 0.3 : 0), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)

            Divider().background(Color.white.opacity(0.1))

            // Emoji grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(categories[selectedCategory].emojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 44, height: 44)
                                .background(selectedEmoji == emoji ? Color.white.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: K.Colors.editorBackground) ?? .black)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

//#Preview {
//    EmojiPickerSheet(selectedEmoji: <#Binding<String>#>)
//}
