//
//  CategoryButtonStyle.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 17/06/2026.
//

import Foundation
import SwiftUI

struct CategoryButtonStyle: ViewModifier {
    let foreground: Color
    let background: Color
    let dashed: Bool

    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: dashed ? [4, 3] : []
                        )
                    )
                    .foregroundStyle(foreground.opacity(0.25))
            }
    }
}
