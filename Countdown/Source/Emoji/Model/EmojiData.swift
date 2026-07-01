//
//  EmojiData.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 25/06/2026.
//

import Foundation

struct EmojiData: Decodable {
    let emoji: String
    let name: String
    let category: String
}

final class EmojiLibrary {
    static let shared = EmojiLibrary()
    
    let all: [EmojiData]
    
    private init() {
        guard let url = Bundle.main.url(forResource: "emojis", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([EmojiData].self, from: data) else {
            all = []
            return
        }
        all = decoded
    }
    
    func search(_ query: String) -> [EmojiData] {
        guard !query.isEmpty else { return all }
        let q = query.lowercased()
        return all.filter { $0.name.contains(q) || $0.category.lowercased().contains(q) }
    }
}
