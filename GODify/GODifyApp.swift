//
//  GODifyApp.swift
//  GODify
//
//  Created by mike on 3/13/26.
//

import SwiftUI

@main
struct GODifyApp: App {
    
    // Use custom app delegate so we can close when last window is closed.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup("GODify") {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New GODify Window") { }
                .disabled(true).keyboardShortcut("n")
            }
        }
    }
}
