//
//  HomeView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 03/02/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeVM = HomeViewModel()
    
    var body: some View {
        NavigationStack {
        VStack {
            Text("Events")
                .fontWeight(.bold)
                
            Spacer()
            
            ForEach(homeVM.events) { event in
                EventView(viewModel: EventViewModel(title: "", date: Date.now, remainingText: "", event: event))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddAnEventView()
                } label: {
                    Image(systemName: "plus")
                }
                .tint(.accentColor)
            }
        }
    }
    }
}

#Preview {
    HomeView()
}
