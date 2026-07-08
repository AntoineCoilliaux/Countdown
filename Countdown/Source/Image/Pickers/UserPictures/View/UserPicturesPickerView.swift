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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if vm.isUploading {
                ProgressView(K.UserPicturesPickerView.progressViewText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                PhotosPicker(
                    selection: $vm.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    // Label vide — le picker s'affiche en mode inline dans le TabView
                    Color.clear
                }
                .photosPickerStyle(.inline)
                .photosPickerDisabledCapabilities(.selectionActions)
                .ignoresSafeArea()
            }
        }
        .onChange(of: vm.selectedItem) { _, newValue in
            guard newValue != nil else { return }
            Task { await vm.uploadSelectedPhoto() }
        }
        .onChange(of: vm.uploadedImageURL) { _, newURL in
            guard let url = newURL else { return }
            onSelect(url)
        }
    }
}

//#Preview {
//    UserPicturesPickerView(onSelect: (URL) -> Void)
//}
