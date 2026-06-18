//
//  CardBackground.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 09/04/2026.
//

import SwiftUI

struct CardBackground: View {
    let borderColor: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor.opacity(0.5), lineWidth: 2)
            )
    }
}

#Preview {
    CardBackground(borderColor: .white)
}
