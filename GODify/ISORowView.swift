//
//  ISORowView.swift
//  GODify
//
//  Created by mike on 3/18/26.
//

import SwiftUI

// represents a single row in the list of ISOs to convert.
struct ISORowView: View {
    @Binding var item: ISOItem
    @Binding var currentIndex: Int
    @Binding var isRunning: Bool
    
    var IndicatorState: ProgressIndicatorState {
        if item.isComplete && !item.isErrored {
            return .Complete;
        } else if isRunning {
            return .Running;
        } else if item.isErrored {
            return .Error;
        } else {
            return .Inactive;
        }
    }
    
    var body: some View {
        HStack {
            ProgressIndicator(CurrentState: self.IndicatorState)
            Text(item.url.lastPathComponent)
        }
    }
}
