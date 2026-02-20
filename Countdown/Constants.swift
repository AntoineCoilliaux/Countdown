//
//  Constants.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import Foundation

struct K {
    struct HomeView {
        static let navigationTitle = "Events"
        static let noEventsYet = "No events yet"
        static let plusButon = "plus"
    }
    
    struct HomeViewModel {
        static let userDefaultsKey = "events"
    }
    
    struct EventView {
        static let arrowUp = "arrow.up"
        static let arrowDown = "arrow.down"
        static let photo = "photo"
    }
    
    struct EditorView {
        static let navigationTitle = "New event"
        static let title = "Title:"
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
        static let photo = "photo"
    }
    
    struct UserPicturesPickerView {
        static let progressViewText = "Uploading..."
        static let pickerText = "Choose from Photos"
        static let pickerDescription = "Select an image from your photo library"
        static let pickerPhoto = "photo.fill.on.rectangle.fill"
    }
    
    struct ImagePickerSheetView {
        static let galleryImage = "photo.on.rectangle"
        static let galleryTitle = "Gallery"
        
        static let photoLibraryImage = "photo.stack"
        static let photoLibraryTitle = "Photos"
    }
    
}
