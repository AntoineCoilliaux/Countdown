//
//  FlagsPickerViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 17/03/2026.
//
import Combine
import Foundation

@MainActor
class FlagsPickerViewModel: ObservableObject {
    @Published var flagURLs: [URL] = []

    func loadFlags() {
        flagURLs = K.Flags.countryCodes.compactMap {
            URL(string: "https://flagcdn.com/w160/\($0).png")
        }
    }
}
