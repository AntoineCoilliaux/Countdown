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
        TabView {
            if network.isConnected {
                OnlinePicturesPickerView { url in
                    onSelect(url)
                }
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text(K.ImagePickerSheetView.galleryTitle)
                }
                
                FlagsPickerView { url in
                    onSelect(url)
                }
                .tabItem {
                    Image(systemName: "flag.2.crossed")
                    Text(K.ImagePickerSheetView.flagTitle)
                }
            }
            UserPicturesPickerView { url in
                onSelect(url)
            }
            .tabItem {
                Image(systemName: "photo.stack")
                Text(K.ImagePickerSheetView.photoLibraryTitle)
            }
        }
    }
}
