//
//  View+Extension.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 09/04/2026.
//

import SwiftUI

extension View {
    func paddingStyle() -> some View {
        self.padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
