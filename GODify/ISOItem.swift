//
//  ISOItem.swift
//  GODify
//
//  Created by mike on 3/13/26.
//


import Foundation

struct ISOItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
}