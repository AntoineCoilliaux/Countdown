//
//  CategoryGradient.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 28/04/2026.
//

import SwiftUI

func categoryGradient(hex: String?, opacity: Double) -> LinearGradient {
    guard let hex else {
        return LinearGradient(
            colors: [.black, .black.opacity(opacity)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    let base = Color(hex: hex) ?? .black
    return LinearGradient(
        colors: [base, base.opacity(opacity)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
