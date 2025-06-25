//
//  CPUDetailView.swift
//  MenuBarApp
//
//  Created by Zoltan Vegh on 23/06/2025.
//

// This app only lives in the menu bar so this file is not needed.
import SwiftUI

struct StatsDetailView: View {
    @ObservedObject var viewModel: ContentViewViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            Text("CPU: ")
            + Text(String(format: "%.2f%%", viewModel.cpuUsage))
                .foregroundColor(viewModel.cpuUsage < 90 ? .green : .red)
            
            Text("RAM: ")
            + Text("\(viewModel.memoryUsage)%")
                .foregroundColor(viewModel.memoryUsage < 90 ? .green : .red)
            
            if let disk = viewModel.diskUsage {
                Text("Free: ")
                + Text(String(format: "%.2f GB", disk.free / (1024*1024*1024)))
                    .foregroundColor(disk.free >= 10 ? .green : .red)
                //+ Text(", Total: \(String(format: "%.2f GB", disk.total / (1024*1024*1024)))")
            } else {
                Text("Disk: N/A")
            }
        }
    }
}

#Preview {
    StatsDetailView(viewModel: ContentViewViewModel())
}
