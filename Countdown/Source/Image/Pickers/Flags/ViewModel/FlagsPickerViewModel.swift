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

    private let urlString = "https://restcountries.com/v3.1/independent?status=true&fields=flags"

    func fetchFlags() async {
        guard countries.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([FlagData].self, from: data)
            self.countries = decoded.sorted { $0.flags.png < $1.flags.png }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
