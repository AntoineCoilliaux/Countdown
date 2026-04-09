//
//  CardBackground.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 09/04/2026.
//

import SwiftUI

struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: K.Colors.editorBackground) ?? .black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    CardBackground()
}
