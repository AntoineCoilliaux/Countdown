//
//  AddAnEventView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct EditorView: View {
    @StateObject var vm = EditorViewModel(mode: .add)
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingImageSheet = false
    @State private var selectedImageURL: URL?
    
    let onSave: (Event) -> Void
    
    init(onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EditorViewModel(mode: .add))
        self.onSave = onSave
    }
    
    init(event: Event, onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EditorViewModel(mode: .edit(existing: event)))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(K.EditorView.navigationTitle)
                    .fontWeight(.bold)
                    .padding(5)
                Spacer()
                Form {
                    HStack(alignment: .top) {
                        Group {
                            if vm.imageName.isLocalImage {
                               localImage
                                
                                
                            } else {
                               onlineImage
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        
                        .onTapGesture {
                            isShowingImageSheet = true
                        }
                        
                        VStack(alignment: .leading) {
                            Text(K.EditorView.title)
                            TextField(K.EditorView.textfieldPlaceholder, text: $vm.name )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    datePicker
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(K.EditorView.doneButton) {
                        if vm.canSave {
                            if let event = try? vm.save() {
                                onSave(event)
                                dismiss()
                            }
                        }
                    }
                    .disabled(!vm.canSave)
                }
            }
        }
        .sheet(isPresented: $isShowingImageSheet) {
            ImagePickerSheetView(
                onGallerySelect: { url in
                    vm.imageName = url
                    isShowingImageSheet = false
                },
                
                onPhotosSelect: { url in
                    vm.imageName = url
                    isShowingImageSheet = false
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    @ViewBuilder
    private var localImage: some View {
        if let filename = vm.imageName.localFilename,
           let fileURL = URL.localImageURL(filename: filename),
           let uiImage = UIImage(contentsOfFile: fileURL.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: K.EditorView.photo)
                .resizable()
                .scaledToFill()
        }
    }
    
    private var onlineImage: some View {
        
        AsyncImage(url: vm.imageName) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
    }
    
    private var datePicker : some View {
        DatePicker(
            "",
            selection: $vm.date,
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.graphical)
    }
}

//#Preview {
//    AddAnEventView(, onSave)
//}

