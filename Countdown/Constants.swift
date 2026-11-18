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
            static let done = LocalizedStringResource("Done")
            static let cancel = LocalizedStringResource("Cancel")
            static let save = LocalizedStringResource("Save")
            static let ok = LocalizedStringResource("OK")
            
            static let createFirstCategory = LocalizedStringResource("Create your first category")
            static let addAnotherCategory = LocalizedStringResource("Add")
            static let editCategory = LocalizedStringResource("Edit")
            static let deleteCategory = LocalizedStringResource("Delete")
        }
        
        struct Category {
            static let deleteAlertTitle = LocalizedStringResource("Delete category?")
            static let deleteOnly = LocalizedStringResource("Delete category only")
            static func deleteWithEvents(count: Int) -> LocalizedStringResource {
                "Delete category and event(s) (\(count))"
            }
            
            static let deleteButton = LocalizedStringResource("Delete category")
            static let deleteWithEventsMessage = LocalizedStringResource("Do you want to delete only the category (events will move to All) or delete the category and its event(s)?")
            static let deleteWithoutEventsMessage = LocalizedStringResource("This category does not contain any event. Are you sure you want to delete it?")
            static let namePlaceholder = LocalizedStringResource("E.g. Birthdays")
            
            static let manageCategories = LocalizedStringResource("Manage categories")

            }
        
        struct Reminder {
            static let remindMe = LocalizedStringResource("Remind me")
        }
    }
    
    struct CountdownWidget {
        static let noEventSelected = LocalizedStringResource("No event selected")
        
        static let displayName = LocalizedStringResource("Countdown")
        static let description = LocalizedStringResource("Make it a widget!")
        
        static let itsOn = LocalizedStringResource("It's on! Tap to create new countdowns!")
    }
    
    struct EditorView {
        static let navigationTitle = LocalizedStringResource("New event")
        
        static let countingDownTo = LocalizedStringResource("Counting down to")
        
        static let date = LocalizedStringResource("Date")
        
        static let textfieldPlaceholder = LocalizedStringResource("E.g. Holidays in Paris")
        static let doneButton = LocalizedStringResource("Done")
        static let none = LocalizedStringResource("None")
        
        static let photoPickerName = LocalizedStringResource("PHOTO")
        static let emojiPickerName = LocalizedStringResource("EMOJI")
        
        static let saveErrorTitle = LocalizedStringResource("Error")
        static let saveErrorDescription = LocalizedStringResource("Could not save the image. Please check your connection.")
        
        static let titleIsTooLongMessage = LocalizedStringResource("Title is too long!")
        
        static let notifyMe = LocalizedStringResource("Notify me when it happens")
    }
    
    struct EventDetailView {
        static let countdownRowDay = LocalizedStringResource("DAY")
        static let countdownRowDays = LocalizedStringResource("DAYS")
        static let countdownRowHours = LocalizedStringResource("HR")
        static let countdownRowMinutes = LocalizedStringResource("MIN")
        static let countdownRowSeconds = LocalizedStringResource("SEC")
        
        static let progressSectionFuture = LocalizedStringResource("% of the wait behind you")
        static let progressSectionPast = LocalizedStringResource("The wait is over!")
        
        static let remindMe = LocalizedStringResource("Remind me")
        static let never = LocalizedStringResource("Never")
    }
    
    struct EventStore {
        static let userDefaultsKeyEvents = "events"
    }
    
    struct EventView {
        static let itsTime = LocalizedStringResource("It's time for")
        static let day = LocalizedStringResource("day")
        static let days = LocalizedStringResource("days")
        static let to = LocalizedStringResource("to")
        static let since = LocalizedStringResource("since")
        static let hourAbbreviation = LocalizedStringResource("h")
        static let minuteAbbreviation = LocalizedStringResource("min")
    }
    
    struct FlagsPickerView {
        static let loadingMessage = LocalizedStringResource("Loading flags...")
        static let errorMessage = LocalizedStringResource("Flags currently unavailable")
    }
    
    struct HomeView {
        static let noEventsYet = LocalizedStringResource("No events yet")
        static let all = LocalizedStringResource("All")
    }
    
    struct ImagePickerSheetView {
        static let galleryTitle = LocalizedStringResource("Gallery")
        static let photoLibraryTitle = LocalizedStringResource("Photos")
        static let flagTitle = LocalizedStringResource("Flags")
    }
    
    struct ManageCategoriesView {
        static let manageCategoriesTitle = LocalizedStringResource("Manage Categories")
        static let alertRenameCategory = LocalizedStringResource("Rename category")
        static let noCategories = LocalizedStringResource("No categories yet")
        static let newCategory = LocalizedStringResource("New category")
        static let editCategory = LocalizedStringResource("Edit category")
    }
    
    struct ReminderPickerView {
        static let custom = LocalizedStringResource("Custom")
        
        static let removeReminder = LocalizedStringResource("Remove custom reminder")
        
        static let scheduled = LocalizedStringResource("SCHEDULED")
        static let inThePast = LocalizedStringResource("In the past")
        static let notificationsDisabledMessage = LocalizedStringResource("Notifications disabled")
        static let enableNotifications = LocalizedStringResource("Enable them in Settings to receive reminders.")
        static let settings = LocalizedStringResource("Settings")
    }
    
    struct SplashView {
        static let appName = LocalizedStringResource("Countdown")
    }
    
    struct UserPicturesPickerView {
        static let progressViewText = LocalizedStringResource("Uploading...")
        static let pickerText = LocalizedStringResource("Choose from Photos")
        static let pickerDescription = LocalizedStringResource("Select an image from your photo library")
    }
    
    struct WidgetDataStore {
        static let suiteName = "group.com.antoine.coilliaux.Countdown"
        static let key = "widgetEvent"
        static let allWidgetsKey = "allWidgetEvents"
    }
    
    struct WidgetTip {
        static let title = LocalizedStringResource("Did you know?")
        static let message = LocalizedStringResource("You can add a widget to your home screen for any event.")
    }
}
