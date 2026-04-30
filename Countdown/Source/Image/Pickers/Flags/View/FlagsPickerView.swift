//
//  FlagsPickerView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 17/03/2026.
//

import Kingfisher
import SwiftUI

struct FlagsPickerView: View {
    @StateObject private var vm = FlagsPickerViewModel()
    var onSelect: (URL) -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(vm.flagURLs, id: \.self) { url in
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                                .frame(width: 100, height: 67)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 67)
                        .clipShape(Rectangle())
                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                        .cornerRadius(8)
                        .onTapGesture { onSelect(url) }
                }
            }
            .padding()
        }
        .onAppear {
            vm.loadFlags()
        }
    }
}

//#Preview {
//    FlagsPickerView()
//}
