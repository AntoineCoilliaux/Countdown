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
            Group {
                if viewModel.event.imageName.isLocalImage {
                    if let filename = viewModel.event.imageName.localFilename,
                       let fileURL = URL.localImageURL(filename: filename),
                       let uiImage = UIImage(contentsOfFile: fileURL.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                    } else {
                        Image(systemName: K.EventView.photo)
                            .resizable()
                    }
                } else {
                    AsyncImage(url: viewModel.event.imageName) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 5))

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
                    
                    Image(systemName: viewModel.isInFuture ? K.EventView.arrowDown : K.EventView.arrowUp)
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
    EventView(viewModel: EventViewModel(event: Event(id: UUID(), name: "Weekend in Paris", date: Date(), imageName: URL(string: "https://fastly.picsum.photos/id/998/300/300.jpg?hmac=CqTPyw23mdWCpY1vSNoWUU5ipnTa6BtTsGc_ztfonWI")!)))
}
