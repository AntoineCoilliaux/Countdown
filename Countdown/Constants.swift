//
//  Constants.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import AppIntents
import Foundation
import SwiftUI

struct K {
    struct CategoryManager {
        static let userDefaultsKeyCategories = "categories"
    }
    
    struct Common {
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
            
            static let manageCategories = "Manage categories"

            }
        
        struct Reminder {
            static let remindMe = "Remind me"
        }
    }
    
    enum Colors {
        static let categoryColors: [(name: String, hex: String)] = [
            ("Lime",     "#C8F135"),
            ("Lavender", "#A78BFA"),
            ("Sky Blue", "#5B9BFF"),
            ("Coral",    "#FF8C66"),
            ("Mint",     "#4DD4AC"),
            ("Rose",     "#FF6B9D"),
            ("Gold",     "#FFD23F"),
            ("Cyan",     "#7DD3FC"),
            ("Magenta",  "#D946EF"),
            ("Amber",    "#F59E0B")
        ]
        static let defaultCategoryHex: String = "#7F1D1D"
        static let appBackground = "#121826"
        static let editorBackground = "#1C1C2E"
        static let red = "#F87171"
        static let green = "#4ADE80"
    }
    
    struct CountdownWidget {
        static let noEventSelected = "No event selected"
        
        static let displayName = "Countdown"
        static let description = "Make it a widget!"
        
        static let itsOn = "It's on! Tap to create new countdowns!"
    }
    
    struct EditorView {
        static let navigationTitle = "New event"
        
        static let countingDownTo = "Counting down to"
        
        static let date = "Date"
        
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
        static let none = "None"
        
        static let photoPickerName = "PHOTO"
        static let emojiPickerName = "EMOJI"
        
        static let saveErrorTitle = "Error"
        static let saveErrorDescription = "Could not save the image. Please check your connection."
        
        static let titleIsTooLongMessage = "Title is too long!"
        
        static let notifyMe = "Notify me when it happens"
    }
    
    struct EventDetailView {
        static let countdownRowDay = "DAY"
        static let countdownRowDays = "DAYS"
        static let countdownRowHours = "HR"
        static let countdownRowMinutes = "MIN"
        static let countdownRowSeconds = "SEC"
        
        static let progressSectionFuture = "% of the wait behind you"
        static let progressSectionPast = "The wait is over!"
        
        static let remindMe = "Remind me"
        static let never = "Never"
    }
    
    struct EventStore {
        static let userDefaultsKeyEvents = "events"
    }
    
    struct EventView {
        static let itsTime = "It's time for"
        static let day = "day"
        static let days = "days"
        static let to = "to"
        static let since = "since"
        static let hourAbbreviation = "h"
        static let minuteAbbreviation = "min"
    }
    
    struct FlagsPickerView {
        static let loadingMessage = "Loading flags..."
        static let errorMessage = "Flags currently unavailable"
    }
    
    struct HomeView {
        static let noEventsYet = "No events yet"
        static let all = "All"
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
    
    struct WidgetTip {
        static let title = "Did you know?"
        static let message = "You can add a widget to your home screen for any event."
    }
}
