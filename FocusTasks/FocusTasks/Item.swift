//
//  Item.swift
//  FocusTasks
//
//  Created by Князь on 16.10.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
