//
//  HomeViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//
import Combine
import Foundation

class HomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    func addEvent(_ event: Event) {
            events.append(event)
        }
}
