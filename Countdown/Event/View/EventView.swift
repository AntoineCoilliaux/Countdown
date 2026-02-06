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
                Text(viewModel.event.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack (alignment: .trailing) {
                HStack {
                    Text(viewModel.dayNumber)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(viewModel.isInFuture ? .green : .red)
                    
                    Image(systemName: viewModel.isInFuture ? K.Event.arrowDown : K.Event.arrowUp)
                }
                Text(viewModel.remainingText)
                    .font(.caption)
                    .foregroundColor(viewModel.isInFuture ? .green : .red)
            }
        }
        .padding()
    }
}



#Preview {
    EventView(viewModel: EventViewModel(event: Event(id: UUID(), name: "Weekend in Paris", date: Date(), imageName: "calendar")))
}

