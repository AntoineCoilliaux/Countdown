//
//  UserPicturesPickerView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import PhotosUI
import SwiftUI

struct UserPicturesPickerView: View {
    @StateObject private var vm = UserPicturesPickerViewModel()
    var onSelect: (URL) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if vm.isUploading {
                ProgressView(K.UserPicturesPickerView.progressViewText)
                    .padding()
            } else {
                photoPicker
                
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
    
    
    private var photoPicker: some View {
        
        return PhotosPicker(
            selection: $vm.selectedItem,
            matching: .images
        ) {
            VStack(spacing: 16) {
                Image(systemName: K.UserPicturesPickerView.pickerPhoto)
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                Text(K.UserPicturesPickerView.pickerText)
                    .font(.title3)
                Text(K.UserPicturesPickerView.pickerDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
}

//#Preview {
//    UserPicturesPickerView(onSelect: (URL) -> Void)
//}
