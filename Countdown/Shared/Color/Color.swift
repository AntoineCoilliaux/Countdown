//
//  Colors.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 08/10/2026.
//

import SwiftUI

// MARK: - Modèles

/// Une couleur avec ses deux variantes (hex).
struct AdaptiveHex {
    let dark: String
    let light: String
}

/// Une couleur de catégorie. Le hex `dark` sert d'identifiant stocké dans les catégories,
/// donc aucune migration des données existantes n'est nécessaire.
struct CategoryColor: Identifiable {
    let name: String
    let dark: String
    let light: String
    var id: String { name }
}

// MARK: - Palette

enum Colors {
    static let categoryColors: [CategoryColor] = [
        .init(name: "Lime",     dark: "#C8F135", light: "#4F7D00"),
        .init(name: "Lavender", dark: "#A78BFA", light: "#6D4AE0"),
        .init(name: "Sky Blue", dark: "#5B9BFF", light: "#1F6FE0"),
        .init(name: "Coral",    dark: "#FF8C66", light: "#D9480F"),
        .init(name: "Mint",     dark: "#4DD4AC", light: "#0B8563"),
        .init(name: "Rose",     dark: "#FF6B9D", light: "#D6336C"),
        .init(name: "Gold",     dark: "#FFD23F", light: "#946C00"),
        .init(name: "Cyan",     dark: "#7DD3FC", light: "#0A7EA4"),
        .init(name: "Magenta",  dark: "#D946EF", light: "#B02CC4"),
        .init(name: "Amber",    dark: "#F59E0B", light: "#B45309")
    ]

    /// Hex stocké pour une catégorie par défaut (clé, pas une couleur affichée telle quelle en light).
    static let defaultCategoryHex: String = "#7F1D1D"

    static let appBackground    = AdaptiveHex(dark: "#121826", light: "#F4F5F9")
    static let editorBackground = AdaptiveHex(dark: "#1C1C2E", light: "#FFFFFF")
    static let red              = AdaptiveHex(dark: "#F87171", light: "#DC2626")
    static let green            = AdaptiveHex(dark: "#4ADE80", light: "#15803D")

    // Fond principal de l'écran (remplace .black) et texte/cartes sémantiques
    static let screenBackground = AdaptiveHex(dark: "#000000", light: "#F4F5F9")
    static let textPrimary      = AdaptiveHex(dark: "#FFFFFF", light: "#111827")
}

// MARK: - Color helpers

extension Color {
    /// Couleur qui s'adapte automatiquement au mode clair / sombre.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    init(adaptive: AdaptiveHex) {
        self.init(
            light: Color(hex: adaptive.light) ?? .black,
            dark: Color(hex: adaptive.dark) ?? .white
        )
    }

    /// Couleur d'une catégorie à partir du hex stocké (variante dark = clé).
    /// Si le hex n'est pas dans la palette, on le renvoie tel quel.
    static func category(hex: String) -> Color {
        guard let pair = Colors.categoryColors.first(where: {
            $0.dark.caseInsensitiveCompare(hex) == .orderedSame
        }),
              let dark = Color(hex: pair.dark),
              let light = Color(hex: pair.light)
        else { return Color(hex: hex) ?? .white }
        return Color(light: light, dark: dark)
    }

    // Raccourcis sémantiques
    static let appBackground = Color(adaptive: Colors.appBackground)
    static let editorBackground = Color(adaptive: Colors.editorBackground)
    static let screenBackground = Color(adaptive: Colors.screenBackground)
    static let textPrimary = Color(adaptive: Colors.textPrimary)
    static let cardFill = Color(light: Color.black.opacity(0.05), dark: Color.white.opacity(0.06))
    static let onCategory = Color(light: .white, dark: .black)
    static let appRed = Color(adaptive: Colors.red)
    static let appGreen = Color(adaptive: Colors.green)
}
