//
//  Constants.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import Foundation

struct K {
    struct Home {
        static let navigationTitle = "Events"
        static let noEventsYet = "No events yet"
    }
    
    struct Event {
        static let arrowUp = "arrow.up"
        static let arrowDown = "arrow.down"
    }
    
    struct AddAnEvent {
        static let navigationTitle = "New event"
        static let title = "Title:"
        static let textfieldPlaceholder = "E.g. Holidays in Paris"
        static let doneButton = "Done"
    }
    
    struct userDefaultsKeys {
        static let events = "events"
    }
}
