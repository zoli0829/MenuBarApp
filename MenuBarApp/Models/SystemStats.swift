//
//  CPUStats.swift
//  MenuBarApp
//
//  Created by Zoltan Vegh on 23/06/2025.
//

import Foundation

struct SystemStats {
    static func getCPUUsage() -> Double {
        var kr: kern_return_t
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        var size = MemoryLayout<host_cpu_load_info_data_t>.stride
        var cpuInfo = host_cpu_load_info()
        
        kr = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if kr != KERN_SUCCESS {
            return -1
        }
        
        let user = Double(cpuInfo.cpu_ticks.0)
        let system = Double(cpuInfo.cpu_ticks.1)
        let idle = Double(cpuInfo.cpu_ticks.2)
        let nice = Double(cpuInfo.cpu_ticks.3)
        
        let totalTicks = user + system + idle + nice
        let totalUsed = totalTicks - idle
        
        return (totalUsed / totalTicks) * 100
    }

    static func getMemoryUsage() -> (used: Double, total: Double)? {
        var stats = vm_statistics64()
        var count = HOST_VM_INFO64 // og was HOST_VM_INFO64_COUNT
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return nil }
        
        let pageSize = vm_page_size
        let used = Double(stats.active_count + stats.inactive_count + stats.wire_count) * Double(pageSize)
        let total = Double(stats.active_count + stats.inactive_count + stats.wire_count + stats.free_count) * Double(pageSize)
        
        return (used, total)
    }

    static func getDiskUsage() -> (free: Double, total: Double)? {
        let fileURL = URL(fileURLWithPath: "/")
        
        do {
            // Key for the volume’s available capacity in bytes (read-only).
            // If I use this, this has an even larger difference.
            //let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
            
            // Key for the volume’s available capacity in bytes for storing important resources (read-only).
            // This one shows different values than what the System Settings shows.
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
            
            // volumeAvailableCapacity
            if let free = values.volumeAvailableCapacityForImportantUsage,
               let total = values.volumeTotalCapacity {
                return (Double(free), Double(total))
            }
        } catch {
            print("Error retrieving storage info: \(error)")
        }
        
        return nil
    }
}


