//
//  CategoryEventRow.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 27/03/2026.
//

import SwiftUI

struct CategoryEventRow: View {
    let event: Event
    
    private var isInFuture: Bool { event.date >= Date() }
    
    var body: some View {
        HStack {
            Image(systemName: isInFuture ? "arrow.down" : "arrow.up")
                .foregroundStyle(isInFuture ? Color(hex: K.Colors.green) ?? .green : Color(hex: K.Colors.red) ?? .red)
            Text(event.name)
            Spacer()
            Text(event.date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.leading, 8)
    }
}

//#Preview {
//    CategoryEventRow()
//}
