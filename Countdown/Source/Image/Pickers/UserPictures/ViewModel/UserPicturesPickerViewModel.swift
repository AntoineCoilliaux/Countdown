//
//  UserPicturesPickerViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 19/02/2026.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
class UserPicturesPickerViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    @Published var uploadedImageURL: URL?
    @Published var isUploading = false
    @Published var errorMessage: String?
    
    func uploadSelectedPhoto() async {
        guard let item = selectedItem else { return }
        
        isUploading = true
        errorMessage = nil
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw NSError(domain: "PhotoUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load image data"])
            }
            
            if let filename = saveImageLocally(imageData: data) {
                uploadedImageURL = URL(string: "local://\(filename)")
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isUploading = false
    }
    
    private func saveImageLocally(imageData: Data) -> String? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        let maxSize: CGFloat = 600
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        guard let compressed = resized.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let eventImagesURL = appSupportURL.appendingPathComponent("EventImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: eventImagesURL, withIntermediateDirectories: true)
        
        let fileURL = eventImagesURL.appendingPathComponent(filename)
        
        do {
            try compressed.write(to: fileURL)
            return filename
        } catch {
            return nil
        }
    }
}
