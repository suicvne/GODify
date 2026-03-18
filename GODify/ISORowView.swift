//
//  ISORowView.swift
//  GODify
//
//  Created by mike on 3/18/26.
//

import SwiftUI

// represents a single row in the list of ISOs to convert.
struct ISORowView: View {
    let item: ISOItem
    let index: Int
    @Binding var currentIndex: Int
    @Binding var isRunning: Bool
    
    var IndicatorState: ProgressIndicatorState {
        if index < currentIndex {
            return .Complete
        } else if index == currentIndex && isRunning {
            return .Running;
        } else {
            return .Inactive
        }
    }
    
    var body: some View {
        HStack {
            ProgressIndicator(CurrentState: self.IndicatorState)
            Text(item.url.lastPathComponent)
        }
    }
}
