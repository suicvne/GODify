//
//  AppDelegate.swift
//  GODify
//
//  Created by mike on 3/13/26.
//


import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return !checkJobRunning();
    }
    
    // So we don't quit in the middle of shit going.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let Response: NSApplication.TerminateReply = !checkJobRunning() || SharedAppState.shared.isTerminating ? .terminateNow : .terminateLater
        return Response;
    }
    
    func checkJobRunning() -> Bool {
        if SharedAppState.shared.isRunning {
            let alert = NSAlert()
            alert.messageText = "Conversion in progress"
            alert.informativeText = "A conversion is currently running. Are you sure you want to quit?"
            alert.alertStyle = .warning

            alert.addButton(withTitle: "Quit")
            alert.addButton(withTitle: "Cancel")

            let result = alert.runModal()

            if result == .alertFirstButtonReturn {
                SharedAppState.shared.isTerminating = true;
                return true
            }
        }
        return false;
    }
}
