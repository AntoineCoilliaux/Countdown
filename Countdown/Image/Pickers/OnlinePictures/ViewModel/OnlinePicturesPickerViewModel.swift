//
//  OnlinePicturesPickerViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/02/2026.
//

import Combine
import Foundation

class OnlinePicturesPickerViewModel: ObservableObject {
    var images: [URL] = []

    func loadRandomImages() {
        var newImages: [URL] = []

        for i in 1..<100 {
            if let url = URL(string: "https://picsum.photos/seed/\(i)/300/300") {
                newImages.append(url)
            }
        }
        self.images = newImages
    }
}
