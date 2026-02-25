//
//  URL+Extension.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 20/02/2026.
//

import Foundation

extension URL {
    static func localImageURL(filename: String) -> URL? {
        guard let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        
        let eventImagesURL = appSupportURL.appendingPathComponent("EventImages", isDirectory: true)
        return eventImagesURL.appendingPathComponent(filename)
    }
    
    var isLocalImage: Bool {
        scheme == "local"
    }
    
    var localFilename: String? {
        guard isLocalImage else { return nil }
        return absoluteString.replacingOccurrences(of: "local://", with: "")

    }
}
