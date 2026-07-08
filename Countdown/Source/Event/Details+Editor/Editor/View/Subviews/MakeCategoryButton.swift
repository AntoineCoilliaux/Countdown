//
//  MakeCategoryButton.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 09/04/2026.
//

import SwiftUI

struct MakeCategoryButton: View {
    let imageName: String
    let text: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(color)
                Text(text)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    MakeCategoryButton(
        imageName: "folder",
        text: "New Category",
        color: .accentColor,
        action: {}
    )
    .padding()
}
