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
        let filename = UUID().uuidString + ".jpg"

        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                return nil
            }
        
        let eventImagesURL = appSupportURL.appendingPathComponent("EventImages", isDirectory: true)
           try? FileManager.default.createDirectory(at: eventImagesURL, withIntermediateDirectories: true)
           
           let fileURL = eventImagesURL.appendingPathComponent(filename)
           
           do {
               try imageData.write(to: fileURL)
               return filename
           } catch {
               print("Error saving image:", error)
               return nil
           }
       }
}
