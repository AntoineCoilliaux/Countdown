//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(K.Home.navigationTitle)
                    .fontWeight(.bold)
                    .padding(5)
                
                if !vm.events.isEmpty {
                    List {
                        ForEach(vm.events) { event in
                            NavigationLink {

                                EventEditorView(event: event) { updatedEvent in
                                    vm.updateEvent(updatedEvent)
                                }
                                
                            } label: {
                                EventView(viewModel: EventViewModel(event: event))
                            }
                        }
                        .onDelete { indexSet in
                            vm.deleteEvent(indexSet)
                        }
                    }
                    
                } else {
                    
                    Spacer()
                    Text(K.Home.noEventsYet)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                vm.events = vm.loadEvents()
                vm.sortEvents()
            }
            .sheet(isPresented: $showingAddEvent) {
                EventEditorView { newEvent in
                    vm.addEvent(newEvent)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
