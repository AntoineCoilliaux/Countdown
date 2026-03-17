📱 Countdown

Countdown is an iOS application that lets users create and track important events with a real-time countdown.

✨ Features

➕ Create custom events with:

Name

Date

Image (photo or visual)

Optional category

⏳ Live countdown:

Displays time remaining for upcoming events

Automatically updates in real time

📊 Smart sorting:

Future events → sorted from the most imminent to the furthest

Past events → sorted from the most recent to the oldest

🗂 Category management:

Create, rename, and delete categories

Filter events by category

🖼 Flexible visuals:

Attach images to events for better personalization

🧠 How it works

The app continuously sorts events based on the current date:

Upcoming events are prioritized and displayed first

Past events remain accessible and are sorted separately

A timer ensures that the UI stays up to date without requiring manual refresh.

🛠 Tech Stack

Swift

SwiftUI

Combine

UserDefaults for local persistence

MVVM architecture

📂 Architecture Overview

EventStore
Centralized data manager handling:

CRUD operations

Sorting logic

Persistence

CategoryManager
Handles category logic and interactions with events

HomeViewModel
Combines events and selected category to produce filtered data for the UI

🚀 Future Improvements

Possibility to make widgets from events

Image caching and offline support

iCloud sync

Notifications for upcoming events

📸 Example Use Cases

Track upcoming holidays ✈️

Count down to birthdays 🎂

Remember past milestones 📅

Organize events by category (F1 GPs, Trips, Work Deadlines..)

📌 Notes

All data is stored locally on the device. No account or internet connection is required for core functionality.
