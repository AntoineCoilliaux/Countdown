//
//  AddAnEventView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct EventEditorView: View {
    @StateObject var vm = EventEditorViewModel(mode: .add)
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingImageSheet = false
    @State private var selectedImageURL: URL?
    
    let onSave: (Event) -> Void
    
    init(onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EventEditorViewModel(mode: .add))
        self.onSave = onSave
    }
    
    // Initializer pour MODE EDIT
    init(event: Event, onSave: @escaping (Event) -> Void) {
        _vm = StateObject(wrappedValue: EventEditorViewModel(mode: .edit(existing: event)))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(K.AddAnEvent.navigationTitle)
                    .fontWeight(.bold)
                    .padding(5)
                Spacer()
                Form {
                    HStack(alignment: .top) {
                        AsyncImage(url: vm.imageName) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 5))
                        
                        .onTapGesture {
                                isShowingImageSheet = true
                            }
                        
                        VStack(alignment: .leading) {
                            Text(K.AddAnEvent.title)
                            TextField(K.AddAnEvent.textfieldPlaceholder, text: $vm.name )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    DatePicker(
                        "",
                        selection: $vm.date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(K.AddAnEvent.doneButton) {
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
            EventImagePickerSheet(
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
}

//#Preview {
//    AddAnEventView(, onSave)
//}
