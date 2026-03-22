//
//  ISOItem.swift
//  GODify
//
//  Created by mike on 3/13/26.
//

import SwiftUI
import Foundation

struct ISOItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    
    public var isErrored: Bool = false;
    public var isComplete: Bool = false;
}
