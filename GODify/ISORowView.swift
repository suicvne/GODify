//
//  ISORowView.swift
//  GODify
//
//  Created by mike on 3/18/26.
//

import SwiftUI

// represents a single row in the list of ISOs to convert.
struct ISORowView: View {
    @Binding var currentIndex: Int;
             let rowIndex: Int;
    @Binding var isRunning: Bool;
    
    // New:
               let IsoURL: URL;
    @Binding   var isComplete: Bool;
    @Binding   var isErrored: Bool;
    
    var IndicatorState: ProgressIndicatorState {
        if isComplete && !isErrored {
            return .Complete;
        } else if isRunning &&
                  currentIndex == rowIndex {
            return .Running;
        } else if isErrored {
            return .Error;
        } else {
            return .Inactive;
        }
    }
    
    var body: some View {
        HStack {
            ProgressIndicator(CurrentState: self.IndicatorState)
            Text(IsoURL.lastPathComponent) // Main text shows file name
                .help(IsoURL.path)         // tooltip shows full
        }
    }
}
