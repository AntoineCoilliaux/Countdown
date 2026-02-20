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
                Text(K.HomeView.navigationTitle)
                    .fontWeight(.bold)
                    .padding(5)
                
                if !vm.events.isEmpty {
                    List {
                        ForEach(vm.events) { event in
                            NavigationLink {

                                EditorView(event: event) { updatedEvent in
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
                    Text(K.HomeView.noEventsYet)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: K.HomeView.plusButon)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                vm.events = vm.loadEvents()
                vm.sortEvents()
            }
            .sheet(isPresented: $showingAddEvent) {
                EditorView { newEvent in
                    vm.addEvent(newEvent)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
