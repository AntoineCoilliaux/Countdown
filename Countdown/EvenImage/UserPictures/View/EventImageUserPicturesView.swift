//
//  EventImageUserPicturesView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import PhotosUI
import SwiftUI

struct EventImageUserPicturesView: View {
    @StateObject private var vm = EventImageUserPicturesViewModel()
    var onSelect: (URL) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if vm.isUploading {
                ProgressView("Uploading...")
                    .padding()
            } else {
                PhotosPicker(
                    selection: $vm.selectedItem,
                    matching: .images
                ) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        Text("Choose from Photos")
                            .font(.title3)
                        Text("Select an image from your photo library")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
                
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .onChange(of: vm.selectedItem) { _, newValue in
            guard newValue != nil else { return }
            Task {
                await vm.uploadSelectedPhoto()
            }
        }
        .onChange(of: vm.uploadedImageURL) { _, newURL in
            guard let url = newURL else { return }
            onSelect(url)
        }
    }
}

//#Preview {
//    EventImageUserPicturesView(onSelect: (URL) -> Void)
//}
