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
                
                if vm.events.isEmpty {
                    Spacer()
                    Text("No events yet")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(vm.events) { event in
                        EventView(viewModel: EventViewModel(event: event))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddAnEventView { newEvent in
                    vm.addEvent(newEvent)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
