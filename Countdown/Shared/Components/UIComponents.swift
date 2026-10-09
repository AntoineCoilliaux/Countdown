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
            .background(Color.textPrimary.opacity(0.08))
    }
}

// MARK: - Error Text

struct ErrorText: View {
    var body: some View {
        Text(K.EditorView.titleIsTooLongMessage)
            .font(.footnote)
            .foregroundStyle(Color.appRed)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}
