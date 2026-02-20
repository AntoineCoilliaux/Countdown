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

class UserPicturesPickerViewModel: ObservableObject {
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
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw NSError(domain: "PhotoUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load image data"])
            }
            
            let filename = saveImageLocally(imageData: data)
            
            if let filename = filename {
                let url = URL(string: "local://\(filename)")!
                
                await MainActor.run {
                    self.uploadedImageURL = url
                    self.isUploading = false
                }
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isUploading = false
            }
        }
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
