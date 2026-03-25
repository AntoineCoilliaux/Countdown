//
//  Constants.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import Foundation

struct K {
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
    
    enum Colors {
        static let categoryColors: [(name: String, hex: String)] = [
            ("Red",    "#FF453A"),
            ("Orange", "#FF9F0A"),
            ("Yellow", "#FFD60A"),
            ("Green",  "#30D158"),
            ("Teal",   "#5AC8FA"),
            ("Blue",   "#0A84FF"),
            ("Purple", "#BF5AF2"),
            ("Gray",   "#8E8E93"),
            ("Brown",  "#A2845E"),
            ("Black",  "#000000")
        ]
    }
    
    struct EditorView {
        static let navigationTitle = "New event"
        static let titleHeader = "Title"
        static let categoryHeader = "Category"
        static let dateHeader = "Date"
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
        static let createACategory = "Create a category"
        static let categoryPicker = "Category"
        static let none = "None"
        
        static let addAnotherCategory = "Add another category"
        static let editCategory = "Edit category"
        static let deleteCategory = "Delete category"
        
        static let saveErrorTitle = "Error"
        static let saveErrorDescription = "Could not save the image. Please check your connection."
        static let saveErrorOKButton = "OK"
        
        static let newCategory = "New category"
        static let newCategoryPlaceholder = "E.g. Birthdays"
        static let newCategorySaveButton = "Save"
        static let newCategoryCancelButton = "Cancel"
        
        static let alertDeleteCategory = "Delete category?"
        static let alertDeleteCategoryOnly = "Delete category only"
        static func alertDeleteCategoryAndEvents(count: Int) -> String {
         "Delete category and events (\(count))"
    }
        static let alertDelete = "Delete category"
        static let alertDeleteCategoryCancelButton = "Cancel"
        static let alertDeleteCategoryWithEventsMessage = "Do you want to delete only the category (events will move to All) or delete the category and its event(s)?"
        static let alertDeleteCategoryWithoutEventsMessage = "This category does not contain any event. Are you sure you want to delete it?"
    }
    
    struct EventStore {
        static let userDefaultsKeyEvents = "events"
    }
    
    struct FlagsPickerView {
        static let loadingMessage = "Loading flags..."
    }
    
    struct HomeView {
        static let noEventsYet = "No events yet"
    }
    
    struct ImagePickerSheetView {
        static let galleryTitle = "Gallery"
        static let photoLibraryTitle = "Photos"
        static let flagTitle = "Flags"
    }
    
    struct ManageCategoriesView {
        static let manageCategoriesTitle = "Manage Categories"
        static let doneButton = "Done"
        
        static let alertDeleteCategory = "Delete category?"
        static let alertDeleteCategoryOnly = "Delete category only"
        static let alertDeleteCategoryAndEvents = "Delete category and events"
        static let alertDeleteCategoryCancelButton = "Cancel"
        static let alertMessage = "Do you want to delete only the category (events will move to All) or delete the category and all its events?"
        
        static let alertRenameCategory = "Rename category"
        static let alertRenameCategoryNameText = "Category name"
        static let alertRenameCategorySaveButton = "Save"
        static let alertRenameCategoryCancelButton = "Cancel"
    }
    
    struct UserPicturesPickerView {
        static let progressViewText = "Uploading..."
        static let pickerText = "Choose from Photos"
        static let pickerDescription = "Select an image from your photo library"
    }
    
}
