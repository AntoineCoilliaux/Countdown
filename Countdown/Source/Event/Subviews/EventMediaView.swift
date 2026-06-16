//
//  EventMediaView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 16/06/2026.
//

import SwiftUI

struct EventMediaView<ImageContent: View>: View {
    let displayMode: EventDisplayMode
    let emoji: String?
    let categoryColor: Color
    let emojiHeight: CGFloat
    let photoHeight: CGFloat
    let imageContent: () -> ImageContent

    var body: some View {
        Group {
            if displayMode == .emoji {
                ZStack {
                    LinearGradient(
                        colors: [categoryColor.opacity(0.35), categoryColor.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Text(emoji ?? "")
                        .font(.system(size: 52))
                }
                .frame(height: emojiHeight)
                .frame(maxWidth: .infinity)
            } else {
                ZStack {
                    imageContent()
                        .blur(radius: 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: photoHeight)
                        .clipped()

                    imageContent()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: photoHeight)
                        .clipped()
                }
                .frame(maxWidth: .infinity)
                .clipped()
            }
        }
        .clipped()
    }
}
