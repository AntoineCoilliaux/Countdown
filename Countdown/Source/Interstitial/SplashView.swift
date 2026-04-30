//
//  SplahView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 29/04/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var isFinished = false
    
    var body: some View {
        if isFinished {
            HomeView()
        } else {
            ZStack {
                Color(hex: K.Colors.appBackground)
                    .ignoresSafeArea()

                Image("CountdownIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(y: -30)

                Text("Countdown")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#BBD2E1") ?? .white)
                    .opacity(opacity)
                    .offset(y: 100)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1.0
                }
                withAnimation(.easeIn(duration: 1.5)) {
                    scale = 2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isFinished = true
                }
            }
        }
    }
}


#Preview {
    SplashView()
}
