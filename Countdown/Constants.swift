//
//  Constants.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import Foundation

struct K {
    struct HomeView {
        static let noEventsYet = "No events yet"
        static let plusButon = "plus"
    }
    
    struct HomeViewModel {
        static let userDefaultsKeyEvents = "events"
    }
    
    struct CategoryManager {
        static let userDefaultsKeyCategories = "categories"
    }
    
    struct CreateCategoryView {
        static let sectionTitle = "Category Name"
        static let namePlaceholder = "Enter category name"
        static let navigationTitle = "New Category"
        static let cancelButton = "Cancel"
        static let saveButton = "Save"
    }
    
    struct EventView {
        static let arrowUp = "arrow.up"
        static let arrowDown = "arrow.down"
        static let photo = "photo"
    }
    
    struct EditorView {
        static let navigationTitle = "New event"
        static let titleHeader = "Title"
        static let categoryHeader = "Category"
        static let dateHeader = "Date"
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
        static let photo = "photo"
        static let plusCircleFillSymbol = "plus.circle.fill"
        static let plusCircleSymbol = "plus.circle"
        static let createACategory = "Create a category"
        static let categoryPicker = "Category"
        static let none = "None"
        static let addAnotherCategory = "Add another category"
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
