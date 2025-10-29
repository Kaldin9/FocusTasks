//
//  Task.swift
//  FocusTasks
//
//  Created by Князь on 18.10.2025.
//


import Foundation

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool

    init(id: UUID = UUID(), title: String, isDone: Bool = false) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isDone = isDone
    }
}