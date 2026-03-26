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
            ("Red",    "#7F1D1D"),
            ("Yellow", "#854D0E"),
            ("Green",  "#14532D"),
            ("Teal",   "#134E4A"),
            ("Blue",   "#1E3A5F"),
            ("Purple", "#3B0764"),
            ("Pink",   "#831843"),
            ("Gray",   "#1F2937"),
            ("Brown",  "#431407")
        ]
        static let appBackground = "#121826"
        static let editorBackground = "#1C1C2E"
        static let red = "#F87171"
        static let green = "#4ADE80"
    }
    
    struct EditorView {
        static let navigationTitle = "New event"
        static let titleHeader = "Title"
        static let categoryHeader = "Category"
        static let dateHeader = "Date"
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
        static let createACategory = "Create a category"
        static let categoryPicker = "Pick a category"
        static let none = "None"
        
        static let addAnotherCategory = "Add"
        static let editCategory = "Edit"
        static let deleteCategory = "Delete"
        
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
