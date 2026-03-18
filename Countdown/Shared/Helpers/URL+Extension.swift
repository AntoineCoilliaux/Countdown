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
    
    static func saveImageFromURL(_ remoteURL: URL) async -> URL? {
        guard let (data, _) = try? await URLSession.shared.data(from: remoteURL) else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        guard let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return nil }
        
        let eventImagesURL = appSupportURL.appendingPathComponent("EventImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: eventImagesURL, withIntermediateDirectories: true)
        
        let fileURL = eventImagesURL.appendingPathComponent(filename)
        guard (try? data.write(to: fileURL)) != nil else { return nil }
        
        return URL(string: "local://\(filename)")
    }
    
    var isLocalImage: Bool {
        scheme == "local"
    }
    
    var localFilename: String? {
        guard isLocalImage else { return nil }
        return absoluteString.replacingOccurrences(of: "local://", with: "")

    }
}
