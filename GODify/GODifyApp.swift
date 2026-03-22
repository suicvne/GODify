//
//  GODifyApp.swift
//  GODify
//
//  Created by mike on 3/13/26.
//

import SwiftUI

@main
struct GODifyApp: App {
    
    @State private var showingAbout = false;
    
    // Use custom app delegate so we can close when last window is closed.
    @NSApplicationDelegateAdaptor(GODifyAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup("GODify") {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About GODify") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "Application by admin@ignoresolutions.xyz\niso2god-rs by iliazeus",
                                attributes: [
                                    NSAttributedString.Key.font:
                                        NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(
                                rawValue: "Copyright"
                            ): "(C) 2026 Mike Santiago"
                        ]
                    )
                }
            }
            CommandGroup(replacing: .newItem) {
                Button("New GODify Window") { }
                .disabled(true).keyboardShortcut("n")
            }
        }
    }
}
