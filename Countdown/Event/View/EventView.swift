//
//  ContentView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 02/02/2026.
//

import SwiftUI

struct EventView: View {
    @ObservedObject var viewModel: EventViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.event.imageName)
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(viewModel.event.name)
                    .font(.headline)
                Text(viewModel.event.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(viewModel.remainingText)
                .font(.caption)
                .foregroundColor(viewModel.isInFuture ? .green : .red)
        }
        .padding()
    }
}



#Preview {
    EventView(viewModel: EventViewModel(event: Event(id: UUID(), name: "ma bite", date: Date(), imageName: "calendar")))
}

