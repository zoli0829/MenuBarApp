//
//  ContentView.swift
//  MenuBarApp
//
//  Created by Zoltan Vegh on 23/06/2025.
//

// This app only lives in the menu bar so this file is not needed.
import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewViewModel()
    
    var body: some View {
        StatsDetailView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
