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
        let size = MemoryLayout<host_cpu_load_info_data_t>.stride
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
    
    /// Retrieves the current memory usage percentage of the system.
    ///
    /// - Returns: An `Int` representing the percentage of used memory, or `nil` if the system call fails.
    static func getMemoryUsage() -> Int? {
        // Create a structure to hold virtual memory statistics
        var stats = vm_statistics64()
        
        // Determine the number of fields in the structure, expressed as a count of integer_t values
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        
        // Call host_statistics64 to fill `stats` with current virtual memory statistics
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        // If the system call failed, return nil
        guard result == KERN_SUCCESS else { return nil }
        
        // Get the system’s memory page size (in bytes)
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)
        
        // Convert various memory page counts to bytes by multiplying by page size
        let active = Double(stats.active_count) * Double(pageSize)   // Actively used memory
        let wired = Double(stats.wire_count)  * Double(pageSize)    // Wired (non-swappable) memory
        let free = Double(stats.free_count)  * Double(pageSize)    // Completely unused memory
        let inactive = Double(stats.inactive_count) * Double(pageSize) // Reclaimable memory
        
        // Calculate total used memory as active + wired
        let used = active + wired
        
        // Calculate total memory as sum of used, free, and inactive memory
        let total = used + free + inactive
        
        // Compute percentage of used memory
        let usagePercent = (used / total) * 100
        
        // Return memory usage percentage as an integer
        return Int(usagePercent)
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


