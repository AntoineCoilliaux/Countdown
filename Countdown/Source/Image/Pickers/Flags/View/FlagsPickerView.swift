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
        Group {
            if vm.isLoading {
                ProgressView(K.FlagsPickerView.loadingMessage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.errorMessage {
                ContentUnavailableView(error, systemImage: "wifi.slash")
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(vm.countries) { country in
                            if let url = URL(string: country.flags.png) {
                                KFImage(url)
                                    .placeholder {
                                        Group {
                                            ProgressView()
                                                .frame(width: 100, height: 100)
                                        }
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
                    }
                    .padding()
                }
            }
        }
        .task { await vm.fetchFlags() }
    }
}

//#Preview {
//    FlagsPickerView()
//}
