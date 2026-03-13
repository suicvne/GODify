//
//  WindowAdapter.swift
//  GODify
//
//  Created by mike on 3/13/26.
//

import AppKit
import SwiftUI
import Combine

// this is just so i can work with the NSWindow on macOS >.>
struct WindowAdapter: NSViewRepresentable {
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            if let window = view.window {
                window.delegate = context.coordinator
                // mark as dirty if hasChanges
                window.isDocumentEdited = SharedAppState.shared.isRunning
            }
        }
        
        context.coordinator.cancellable = SharedAppState.shared.$isRunning.sink { isRunning in
            if let window = view.window {
                window.isDocumentEdited = isRunning;
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            window.isDocumentEdited = SharedAppState.shared.isRunning
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, NSWindowDelegate {
        var cancellable: AnyCancellable?
 
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            guard SharedAppState.shared.isRunning && !SharedAppState.shared.isTerminating else { return true }
            
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
            
            return result == .alertFirstButtonReturn
        }
    }
}
