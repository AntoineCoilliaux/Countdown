//
//  SegmentedOptionButton.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 17/06/2026.
//

import SwiftUI

struct SegmentedOptionButton<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                content
            }
            .font(.system(size: 11, weight: .bold))
            .tracking(0.8)
            .frame(maxWidth: .infinity)
            .frame(height: 25)
            .padding(.vertical, 10)
            .background(isSelected ? Color.white.opacity(0.15) : .clear)
            .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(isSelected ? 0.3 : 0.1), lineWidth: 1)
            }
        }
    }
}

//#Preview {
//    SegmentedOptionButton()
//}
