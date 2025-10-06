//
//  Note.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var category: NoteCategory
    var tags: [String]
    var createdDate: Date
    var modifiedDate: Date
    var linkedTaskIds: [UUID]
    var isFavorite: Bool
    
    init(title: String, content: String = "", category: NoteCategory = .general) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.tags = []
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.linkedTaskIds = []
        self.isFavorite = false
    }
    
    mutating func updateContent(_ newContent: String) {
        self.content = newContent
        self.modifiedDate = Date()
        self.category = NoteCategory.detectCategory(from: newContent)
    }
    
    mutating func updateTitle(_ newTitle: String) {
        self.title = newTitle
        self.modifiedDate = Date()
    }
}

enum NoteCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case ideas = "Ideas"
    case reference = "Reference"
    case meeting = "Meeting"
    case general = "General"
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .personal: return "green"
        case .ideas: return "purple"
        case .reference: return "orange"
        case .meeting: return "red"
        case .general: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .ideas: return "lightbulb.fill"
        case .reference: return "book.fill"
        case .meeting: return "person.3.fill"
        case .general: return "note.text"
        }
    }
    
    static func detectCategory(from content: String) -> NoteCategory {
        let lowercaseContent = content.lowercased()
        
        if lowercaseContent.contains("meeting") || lowercaseContent.contains("agenda") {
            return .meeting
        } else if lowercaseContent.contains("idea") || lowercaseContent.contains("brainstorm") {
            return .ideas
        } else if lowercaseContent.contains("work") || lowercaseContent.contains("project") {
            return .work
        } else if lowercaseContent.contains("reference") || lowercaseContent.contains("documentation") {
            return .reference
        } else if lowercaseContent.contains("personal") || lowercaseContent.contains("family") {
            return .personal
        }
        
        return .general
    }
}
