//
//  ProgressIndicator.swift
//  GODify
//
//  Created by mike on 3/18/26.
//

import SwiftUI

enum ProgressIndicatorState {
    case Inactive
    case Running
    case Complete
}

// Represents a project indicator, sitting somewhere, that transitions from:
// Invisible
// Visible, spinning
// Visible, complete, green check mark.
struct ProgressIndicator: View {
    @State public var CurrentState: ProgressIndicatorState = ProgressIndicatorState.Inactive;
    
    var body: some View {
        switch(CurrentState) {
        case .Inactive:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.small)
                .opacity(0.0)
        case .Running:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.small)
        case .Complete:
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
        }
    }
}
