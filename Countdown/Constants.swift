//
//  Constants.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import AppIntents
import Foundation

struct K {
    struct CategoryManager {
        static let userDefaultsKeyCategories = "categories"
    }
    
    struct Common {
        struct Category {
            static let deleteAlertTitle = "Delete category?"
            static let deleteOnly = "Delete category only"
            static func deleteWithEvents(count: Int) -> String {
                "Delete category and event(s) (\(count))"
            }
            
            static let deleteButton = "Delete category"
            static let deleteWithEventsMessage = "Do you want to delete only the category (events will move to All) or delete the category and its event(s)?"
            static let deleteWithoutEventsMessage = "This category does not contain any event. Are you sure you want to delete it?"
            static let namePlaceholder = "E.g. Birthdays"
            }
        
        struct Buttons {
            static let done = "Done"
            static let cancel = "Cancel"
            static let save = "Save"
            static let ok = "OK"
            
            static let createFirstCategory = "Create your first category"
            static let addAnotherCategory = "Add"
            static let editCategory = "Edit"
            static let deleteCategory = "Delete"
        }
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
        static let defaultCategoryHex: String = "#7F1D1D"
        static let appBackground = "#121826"
        static let editorBackground = "#1C1C2E"
        static let red = "#F87171"
        static let green = "#4ADE80"
    }
    
    struct CountdownWidget {
        static let appIntentTitle : LocalizedStringResource = "Pick an event"
        
        static let appIntentDescription : LocalizedStringResource = "Pick an event for your widget."
        static let parameterTitle : LocalizedStringResource = "Events"
        
        static let typeDisplayRepresentation : TypeDisplayRepresentation = "Event"
        
        static let noEventSelected = "No event selected"
        
        static let displayName = "Countdown"
        static let description = "Choose the event you want to create a widget from."
    }
    
    struct EditorView {
        static let navigationTitle = "New event"
        static let titleHeader = "Title"
        static let categoryHeader = "Category"
        static let dateHeader = "Date"
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
        static let none = "None"
        
        static let saveErrorTitle = "Error"
        static let saveErrorDescription = "Could not save the image. Please check your connection."
        
        static let titleIsTooLongMessage = "Title is too long!"
    }
    
    struct EventStore {
        static let userDefaultsKeyEvents = "events"
    }
    
    struct FlagsPickerView {
        static let loadingMessage = "Loading flags..."
    }
    
    struct HomeView {
        static let noEventsYet = "No events yet"
        static let all = "All"
        static let manageCategories = "Manage categories"
    }
    
    struct ImagePickerSheetView {
        static let galleryTitle = "Gallery"
        static let photoLibraryTitle = "Photos"
        static let flagTitle = "Flags"
    }
    
    struct ManageCategoriesView {
        static let manageCategoriesTitle = "Manage Categories"
        static let alertRenameCategory = "Rename category"
        static let noCategories = "No categories yet"
        static let newCategory = "New category"
        static let editCategory = "Edit category"
    }
    
    struct UserPicturesPickerView {
        static let progressViewText = "Uploading..."
        static let pickerText = "Choose from Photos"
        static let pickerDescription = "Select an image from your photo library"
    }
    
    struct WidgetDataStore {
        static let suiteName = "group.com.antoine.coilliaux.Countdown"
        static let key = "widgetEvent"
        static let allWidgetsKey = "allWidgetEvents"
    }
}
