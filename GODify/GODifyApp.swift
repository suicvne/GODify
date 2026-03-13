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
        Window("GODify", id: "main") {
            ContentView()
        }
    }
}
