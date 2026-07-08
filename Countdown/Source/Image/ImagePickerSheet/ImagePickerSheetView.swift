//
//  ImagePickerSheetView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import SwiftUI

struct ImagePickerSheetView: View {
    @StateObject private var network = NetworkMonitor()

    var onSelect: (URL) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 44)

            TabView {
                if network.isConnected {
                    OnlinePicturesPickerView { url in onSelect(url) }
                        .tabItem {
                            Image(systemName: "photo.on.rectangle")
                            Text(K.ImagePickerSheetView.galleryTitle)
                        }
                }
                UserPicturesPickerView { url in onSelect(url) }
                    .tabItem {
                        Image(systemName: "photo.stack")
                        Text(K.ImagePickerSheetView.photoLibraryTitle)
                    }
            }
        }
    }
}
