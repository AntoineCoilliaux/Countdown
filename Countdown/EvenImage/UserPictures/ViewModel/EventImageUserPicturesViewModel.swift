//
//  EventImageUserPicturesViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

class EventImageUserPicturesViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    @Published var uploadedImageURL: URL?
    @Published var isUploading = false
    @Published var errorMessage: String?
    
    func uploadSelectedPhoto() async {
        guard let item = selectedItem else { return }
        
        await MainActor.run {
            isUploading = true
            errorMessage = nil
        }
        
        do {
            // 1. Charger les données de l'image
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw NSError(domain: "PhotoUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load image data"])
            }
            
            // 2. Upload vers ton service (Imgur, Cloudinary, etc.)
            let url = saveImageLocally(imageData: data)
            
            await MainActor.run {
                self.uploadedImageURL = url
                self.isUploading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isUploading = false
            }
        }
    }
    
    private func saveImageLocally(imageData: Data) -> URL? {
        let filename = UUID().uuidString + ".jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image:", error)
            return nil
        }
    }
}
