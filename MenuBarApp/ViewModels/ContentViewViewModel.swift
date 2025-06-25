//
//  ContentViewViewModel.swift
//  MenuBarApp
//
//  Created by Zoltan Vegh on 25/06/2025.
//

// This app only lives in the menu bar so this file is not needed.
import Combine
import Foundation

class ContentViewViewModel: ObservableObject {
    // Published properties for the UI to bind to
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Int = 0
    @Published var diskUsage: (free: Double, total: Double)? = nil

    private var timer: Timer?

    init() {
        // Start timer to update stats every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateStats()
        }
    }

    private func updateStats() {
        cpuUsage = SystemStats.getCPUUsage()
        memoryUsage = SystemStats.getMemoryUsage() ?? 0
        diskUsage = SystemStats.getDiskUsage()
    }

    deinit {
        // Invalidate the timer when the view model is deallocated
        timer?.invalidate()
    }
}
