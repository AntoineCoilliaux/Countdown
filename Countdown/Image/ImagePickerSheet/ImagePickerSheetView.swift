//
//  ImagePickerSheetView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import SwiftUI

struct ImagePickerSheetView: View {
    
    var onGallerySelect: (URL) -> Void
    var onPhotosSelect: (URL) -> Void

    var body: some View {
        TabView {
            OnlinePicturesPickerView { url in
                onGallerySelect(url)
            }
            .tabItem {
                Image(systemName: K.ImagePickerSheetView.galleryImage)
                Text(K.ImagePickerSheetView.galleryTitle)
            }

            UserPicturesPickerView { url in
                onPhotosSelect(url)
            }
            .tabItem {
                Image(systemName: K.ImagePickerSheetView.photoLibraryImage)
                Text(K.ImagePickerSheetView.photoLibraryTitle)
            }
        }
    }
}
