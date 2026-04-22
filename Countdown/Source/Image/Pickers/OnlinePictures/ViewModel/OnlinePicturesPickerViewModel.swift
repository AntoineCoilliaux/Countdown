//
//  OnlinePicturesPickerViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/02/2026.
//

import Combine
import Foundation

class OnlinePicturesPickerViewModel: ObservableObject {
    @Published var images: [URL] = []
    private static var cachedImages: [URL] = []
    
    func loadImages() async {
        if !Self.cachedImages.isEmpty {
            await MainActor.run {
                self.images = Self.cachedImages
            }
            return
        }

        guard let url = URL(string: "https://picsum.photos/v2/list?page=2&limit=99") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode([PicsumImage].self, from: data)

            let urls: [URL] = results.compactMap {
                URL(string: "https://picsum.photos/id/\($0.id)/300/300")
            }

            await MainActor.run {
                Self.cachedImages = urls
                self.images = urls
            }
        } catch {
            let fallback = [URL(string: "https://picsum.photos/id/1/300/300")].compactMap { $0 }
            await MainActor.run {
                self.images.append(contentsOf: fallback)
            }
        }
    }
}
