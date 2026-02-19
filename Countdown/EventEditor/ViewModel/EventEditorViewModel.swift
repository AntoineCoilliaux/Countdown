//
//  EventEditorViewModel.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 05/02/2026.
//

import Foundation
import Combine

final class EventEditorViewModel: ObservableObject {
    @Published var name: String
    @Published var date: Date
    @Published var imageName: URL
    var randomNumber = Int.random(in: 0...50)

      enum Mode {
          case add
          case edit(existing: Event)
      }

      let mode: Mode

      init(mode: Mode) {
          self.mode = mode
          switch mode {
          case .add:
              self.name = ""
              self.date = Date()
              self.imageName = URL(string: "https://picsum.photos/seed/\(randomNumber)/300/300")!
          case .edit(let existing):
              self.name = existing.name
              self.date = existing.date
              self.imageName = existing.imageName
          }
      }

      var canSave: Bool {
          !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      }

      func save() throws -> Event {
          switch mode {
          case .add:
              return Event(id: UUID(), name: name, date: date, imageName: imageName)
          case .edit(let existing):
              return Event(id: existing.id, name: name, date: date, imageName: imageName)
          }
      }
  }
