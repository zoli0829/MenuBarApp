import Cocoa
import SwiftUI

// AppDelegate handles the lifecycle and main logic of the menu bar app
class AppDelegate: NSObject, NSApplicationDelegate {
    // The status bar item that appears on the macOS menu bar
    var statusItem: NSStatusItem!
    
    // Timer to periodically update system stats every second
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a new status item with variable length (adapts to content width)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "Loading..."
        }

        // Create a simple menu with a Quit option
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q" // Command + Q shortcut
            )
        )
        // Assign the menu to the status item
        statusItem.menu = menu

        // Start a repeating timer that triggers updateStats() every 1 second
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateStats),
            userInfo: nil,
            repeats: true
        )
    }

    // Called every second by the timer to refresh system stats shown in the menu bar
    @objc func updateStats() {
        let cpuUsage = SystemStats.getCPUUsage()
        // Fetch current memory usage percentage, default to -1 if unavailable
        let memoryUsage = SystemStats.getMemoryUsage() ?? -1
        
        if let diskUsage = SystemStats.getDiskUsage() {
            // Convert free disk bytes to gigabytes
            let freeGB = diskUsage.free / (1024 * 1024 * 1024)
            
            // Update the status bar text on the main thread (UI update)
            DispatchQueue.main.async {
                self.statusItem.button?.title = String(
                    format: "CPU: %.0f%% | RAM: %d%% | Free: %.1fGB",
                    cpuUsage,
                    memoryUsage,
                    freeGB
                )
            }
        } else {
            // If disk info unavailable, show "Disk: N/A" instead
            DispatchQueue.main.async {
                self.statusItem.button?.title = String(
                    format: "CPU: %.0f%% | RAM: %d%% | Disk: N/A",
                    cpuUsage,
                    memoryUsage
                )
            }
        }
    }
}
