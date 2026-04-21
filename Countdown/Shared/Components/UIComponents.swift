//
//  UIComponents.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 14/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Divider

struct AppDivider: View {
    var body: some View {
        Divider()
            .background(.white.opacity(0.08))
    }
}

// MARK: - Error Text

struct ErrorText: View {
    var body: some View {
        Text(K.EditorView.titleIsTooLongMessage)
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}
