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
    @Published var countries: [FlagData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private static var cachedCountries: [FlagData] = []

    private let urlString = "https://restcountries.com/v3.1/independent?status=true&fields=flags"

    func fetchFlags() async {
        if !Self.cachedCountries.isEmpty {
            self.countries = Self.cachedCountries
            return
        }

        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([FlagData].self, from: data)
            let sorted = decoded.sorted { $0.flags.png < $1.flags.png }
            Self.cachedCountries = sorted
            self.countries = sorted
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
