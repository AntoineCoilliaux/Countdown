//
//  ColorRow.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 24/03/2026.
//

import SwiftUI

struct ColorRow: View {
    let categoryColors: [(name: String, hex: String)]
    @Binding var selectedHex: String?
    let onColorSelected: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 28, height: 28)
                    
                    if selectedHex == nil {
                        Circle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 28, height: 28)
                    }
                }
                .onTapGesture { selectedHex = nil }
                
                ForEach(categoryColors, id: \.hex) { color in
                    Circle()
                        .fill(Color(hex: color.hex) ?? .clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    selectedHex == color.hex ? Color.primary : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            selectedHex = color.hex
                            onColorSelected(color.hex)

                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

//#Preview {
//    ColorRow()
//}
