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

    func loadRandomImages() {
        guard images.isEmpty else { return }
        var newImages: [URL] = []

        for i in 1..<100 {
            if let url = URL(string: "https://picsum.photos/seed/\(i)/300/300") {
                newImages.append(url)
            }
        }
        self.images = newImages
    }
}
