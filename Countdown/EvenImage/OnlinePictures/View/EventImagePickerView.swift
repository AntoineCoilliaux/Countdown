//
//  EventImagePickerView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/02/2026.
//

import SwiftUI

struct EventImagePickerView: View {
    @StateObject var vm = EventImagePickerViewModel()
    var onSelect: (URL) -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(vm.images, id: \.self) { image in
                    AsyncImage(url: image) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                            
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                            
                                .onTapGesture {
                                    onSelect(image)
                                }
                            
                        case .failure:
                            Color.gray
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            vm.loadRandomImages()
        }
    }
}

#Preview {
    EventImagePickerView { selectedUrl in
        print("Selected image URL:", selectedUrl)
    }
}
