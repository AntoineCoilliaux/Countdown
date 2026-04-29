//
//  WidgetTip.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 29/04/2026.
//

import TipKit

struct WidgetTip: Tip {
    static let firstEventCreated = Tips.Event(id: "firstEventCreated")
    
    var title: Text {
        Text(K.WidgetTip.title)
    }
    var message: Text? {
        Text(K.WidgetTip.message)
    }
    var image: Image? {
        Image(systemName: "widget.small")
    }
    
    var rules: [Rule] {
        #Rule(Self.firstEventCreated) { $0.donations.count == 1 }
    }
}
