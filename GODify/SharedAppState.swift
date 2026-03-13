//
//  SharedAppState.swift
//  GODify
//
//  Created by mike on 3/13/26.
//

import Foundation
import Combine

final class SharedAppState: ObservableObject {
    static let shared = SharedAppState()
    @Published var isRunning: Bool = false
    @Published var isTerminating: Bool = false
    
    private init() { }
}
