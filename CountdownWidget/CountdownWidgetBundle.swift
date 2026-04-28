//
//  CountdownWidgetBundle.swift
//  CountdownWidget
//
//  Created by Antoine Coilliaux on 22/04/2026.
//

import WidgetKit
import SwiftUI

struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
        CountdownWidgetControl()
    }
}
