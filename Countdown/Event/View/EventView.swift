//
//  ContentView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI

struct EventView: View {
    @StateObject var viewModel: EventViewModel

    var body: some View {
        HStack {
            Image(systemName: "calendar")

            VStack(alignment: .leading) {
                Text(viewModel.event.name)
                Text(viewModel.formattedDate)
            }

            Spacer()

            Text(viewModel.remainingText)
                .foregroundStyle(
                    viewModel.isInFuture ? .blue : .gray
                )
        }
    }
}



//#Preview {
//    EventView(
//        id: UUID(),
//        image: Image(systemName: "calendar"),
//        name: "Paname",
//        date: "13 février 2026 à 15h45",
//        remainingTime: "10j, 23h, 12s"
//    )
//}

