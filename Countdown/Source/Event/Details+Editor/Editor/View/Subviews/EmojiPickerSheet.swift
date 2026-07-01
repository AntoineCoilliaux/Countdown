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
    @State private var searchQuery = ""
    @State private var selectedCategory = 0

    private var searchResults: [EmojiData] {
        EmojiLibrary.shared.search(searchQuery)
    }

    private var isSearching: Bool {
        !searchQuery.isEmpty
    }

    // Reconstruit la liste de catégories uniques depuis le JSON
    private var categories: [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for item in EmojiLibrary.shared.all {
            if !seen.contains(item.category) {
                seen.insert(item.category)
                ordered.append(item.category)
            }
        }
        return ordered
    }

    private func emojis(for category: String) -> [EmojiData] {
        EmojiLibrary.shared.all.filter { $0.category == category }
    }

    // Un emoji représentatif pour l'icône du tab
    private func categoryIcon(for category: String) -> String {
        emojis(for: category).first?.emoji ?? "❓"
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.4))
                TextField("", text: $searchQuery, prompt: Text("Search")
                    .foregroundStyle(.white.opacity(0.4)))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            if !isSearching {
                HStack(spacing: 4) {
                    ForEach(categories.indices, id: \.self) { i in
                        Button {
                            selectedCategory = i
                        } label: {
                            Text(categoryIcon(for: categories[i]))
                                .font(.system(size: 20))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    selectedCategory == i
                                    ? Color.white.opacity(0.15)
                                    : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            Color.white.opacity(selectedCategory == i ? 0.3 : 0),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                Divider()
                    .background(Color.white.opacity(0.1))
            }

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    if isSearching {
                        ForEach(searchResults, id: \.emoji) { item in
                            emojiButton(item.emoji)
                        }
                    } else {
                        ForEach(emojis(for: categories[selectedCategory]), id: \.emoji) { item in
                            emojiButton(item.emoji)
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: K.Colors.appBackground) ?? .black)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private func emojiButton(_ emoji: String) -> some View {
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
