//
//  ColorRow.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 24/03/2026.
//

import SwiftUI

struct ColorRow: View {
    @Binding var selectedHex: String?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(K.Colors.categoryColors, id: \.hex) { color in
                Circle()
                    .fill(Color(hex: color.hex) ?? .clear)
                    .frame(width: 35, height: 35)
                    .padding(5)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                selectedHex == color.hex ? Color.primary : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .onTapGesture {
                        selectedHex = color.hex
                    }
            }
        }
        .padding(.vertical, 4)
    }
}

//#Preview {
//    ColorRow()
//}
