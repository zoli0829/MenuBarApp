//
//  CPUDetailView.swift
//  MenuBarApp
//
//  Created by Zoltan Vegh on 23/06/2025.
//

import SwiftUI

struct StatsDetailView: View {
    var diskUsageText: Text {
        if let diskUsage = SystemStats.getDiskUsage() {
            let freeGB = diskUsage.free / (1024 * 1024 * 1024)
            let totalGB = diskUsage.total / (1024 * 1024 * 1024)
            let freeString = String(format: "%.2f", freeGB) + " GB"
            let totalString = String(format: "%.2f", totalGB) + " GB"
            
            return Text("Free: \(freeString), Total: \(totalString)")
        } else {
            return Text("N/A")
        }
    }
    
    var cpuUsageText: Text {
        Text("CPU: ") + Text(String(format: "%.2f%%", SystemStats.getCPUUsage()))
    }
    
    var body: some View {
        HStack(spacing: 10) {
            cpuUsageText
            diskUsageText
            
            Text("Here comes the memory usage")
        }
    }
}

#Preview {
    StatsDetailView()
}
