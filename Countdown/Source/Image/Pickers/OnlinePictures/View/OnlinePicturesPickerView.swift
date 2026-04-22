//
//  OnlinePicturesPickerView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 18/02/2026.
//
import Kingfisher
import SwiftUI

struct OnlinePicturesPickerView: View {
    @StateObject var vm = OnlinePicturesPickerViewModel()
    var onSelect: (URL) -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            picGrid
        }
        .onAppear {
            Task {
                await vm.loadImages()
            }
        }
    }
    
    private var picGrid : some View {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(vm.images, id: \.self) { image in
                    KFImage(image)
                        .placeholder {
                            Group {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            }
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                        .onTapGesture {
                            onSelect(image)
                        }
                }
            }
            .padding()
        }
    }


#Preview {
    OnlinePicturesPickerView { selectedUrl in
        print("Selected image URL:", selectedUrl)
    }
}
