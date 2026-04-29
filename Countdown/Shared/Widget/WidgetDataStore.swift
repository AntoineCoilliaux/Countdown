//
//  WidgetDataStore.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 22/04/2026.
//

import Foundation

struct WidgetDataStore {
    private static let suiteName = K.WidgetDataStore.suiteName
    private static let key = K.WidgetDataStore.key
    private static let allWidgetsKey = K.WidgetDataStore.allWidgetsKey  // Nouvelle clé pour la liste complète
    
    // MARK: - AppIntent Methods (Nouvelles méthodes pour le widget configurable)
    
    /// Sauvegarde la liste de tous les événements pour que le Widget puisse les lister
    static func saveAllEvents(_ events: [WidgetEvent]) {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = try? JSONEncoder().encode(events) else { return }
        defaults.set(data, forKey: allWidgetsKey)
    }
    
    /// Charge tous les événements disponibles pour le menu de sélection du Widget
    static func loadAllEvents() -> [WidgetEvent] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: allWidgetsKey),
              let events = try? JSONDecoder().decode([WidgetEvent].self, from: data) else { return [] }
        return events
    }
    
    /// Récupère un événement précis sélectionné par l'utilisateur via son ID
    static func loadSpecificEvent(id: UUID) -> WidgetEvent? {
        return loadAllEvents().first(where: { $0.id == id })
    }
}
