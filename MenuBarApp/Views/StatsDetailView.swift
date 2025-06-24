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
            
            let freeText = Text("\(freeString)")
                .foregroundColor(freeGB >= 10 ? .green : .red)
            let totalText = Text(", Total: \(totalString)")
            
            return Text ("Free: ") + freeText + totalText
        } else {
            return Text("N/A")
        }
    }
    
    var cpuUsageText: Text {
        let cpuUsage = SystemStats.getCPUUsage()
        return Text("CPU: ") + Text(String(format: "%.2f%%", cpuUsage))
            .foregroundColor(cpuUsage < 90 ? .green : .red)
    }
    
    var memoryUsageText: some View {
        if let memoryUsage = SystemStats.getMemoryUsage() {
            return Text("RAM: ") + Text("\(memoryUsage)%")
                .foregroundColor(memoryUsage < 90 ? .green : .red)
        } else {
            return Text("N/A")
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            cpuUsageText
            memoryUsageText
            diskUsageText
        }
    }
}

#Preview {
    StatsDetailView()
}
