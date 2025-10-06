//
//  Task.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Task: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var category: TaskCategory
    var priority: TaskPriority
    var isCompleted: Bool
    var dueDate: Date?
    var createdDate: Date
    var completedDate: Date?
    var linkedNoteIds: [UUID]
    
    init(title: String, description: String = "", category: TaskCategory = .personal, priority: TaskPriority = .medium, dueDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.isCompleted = false
        self.dueDate = dueDate
        self.createdDate = Date()
        self.completedDate = nil
        self.linkedNoteIds = []
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case learning = "Learning"
    case finance = "Finance"
    case other = "Other"
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .personal: return "green"
        case .health: return "red"
        case .learning: return "purple"
        case .finance: return "orange"
        case .other: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .finance: return "dollarsign.circle.fill"
        case .other: return "folder.fill"
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .urgent: return 4
        }
    }
}
