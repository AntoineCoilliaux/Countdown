//
//  EventImagePickerSheet.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import SwiftUI

struct EventImagePickerSheet: View {
    
    var onGallerySelect: (URL) -> Void
    var onPhotosSelect: (URL) -> Void

    var body: some View {
        TabView {
            EventImagePickerView { url in
                onGallerySelect(url)
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle")
                Text("Gallery")
            }

            EventImageUserPicturesView { url in
                onPhotosSelect(url)
            }
            .tabItem {
                Image(systemName: "photo.stack")
                Text("Photos")
            }
        }
    }
}
