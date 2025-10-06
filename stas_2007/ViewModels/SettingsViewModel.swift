//
//  SettingsViewModel.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var isDarkModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDarkModeEnabled, forKey: Constants.UserDefaultsKeys.isDarkModeEnabled)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Constants.UserDefaultsKeys.notificationsEnabled)
        }
    }
    
    @Published var autoSaveEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoSaveEnabled, forKey: Constants.UserDefaultsKeys.autoSaveEnabled)
        }
    }
    
    @Published var defaultTaskCategory: TaskCategory {
        didSet {
            UserDefaults.standard.set(defaultTaskCategory.rawValue, forKey: Constants.UserDefaultsKeys.defaultTaskCategory)
        }
    }
    
    @Published var showResetConfirmation: Bool = false
    @Published var showAboutSheet: Bool = false
    
    private let dataService = DataService.shared
    
    init() {
        self.isDarkModeEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isDarkModeEnabled)
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled)
        self.autoSaveEnabled = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.autoSaveEnabled) as? Bool ?? true
        
        let categoryString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.defaultTaskCategory) ?? TaskCategory.personal.rawValue
        self.defaultTaskCategory = TaskCategory(rawValue: categoryString) ?? .personal
    }
    
    // MARK: - Settings Actions
    
    func resetApp() {
        dataService.resetAllData()
        resetUserDefaults()
        showResetConfirmation = false
    }
    
    private func resetUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.isDarkModeEnabled)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.notificationsEnabled)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.autoSaveEnabled)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.defaultTaskCategory)
        
        // Reset published properties to defaults
        isDarkModeEnabled = false
        notificationsEnabled = false
        autoSaveEnabled = true
        defaultTaskCategory = .personal
    }
    
    func exportData() -> String {
        let tasks = dataService.tasks
        let notes = dataService.notes
        
        var exportString = "ChronoRoad Note Data Export\n"
        exportString += "Generated on: \(DateFormatter.exportFormatter.string(from: Date()))\n\n"
        
        exportString += "=== TASKS ===\n"
        for task in tasks {
            exportString += "Title: \(task.title)\n"
            exportString += "Description: \(task.description)\n"
            exportString += "Category: \(task.category.rawValue)\n"
            exportString += "Priority: \(task.priority.rawValue)\n"
            exportString += "Status: \(task.isCompleted ? "Completed" : "Pending")\n"
            if let dueDate = task.dueDate {
                exportString += "Due Date: \(DateFormatter.exportFormatter.string(from: dueDate))\n"
            }
            exportString += "Created: \(DateFormatter.exportFormatter.string(from: task.createdDate))\n"
            exportString += "\n"
        }
        
        exportString += "=== NOTES ===\n"
        for note in notes {
            exportString += "Title: \(note.title)\n"
            exportString += "Category: \(note.category.rawValue)\n"
            exportString += "Content: \(note.content)\n"
            if !note.tags.isEmpty {
                exportString += "Tags: \(note.tags.joined(separator: ", "))\n"
            }
            exportString += "Created: \(DateFormatter.exportFormatter.string(from: note.createdDate))\n"
            exportString += "Modified: \(DateFormatter.exportFormatter.string(from: note.modifiedDate))\n"
            exportString += "\n"
        }
        
        return exportString
    }
    
    // MARK: - Computed Properties
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? Constants.appVersion
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var totalTasks: Int {
        dataService.tasks.count
    }
    
    var totalNotes: Int {
        dataService.notes.count
    }
    
    var completedTasks: Int {
        dataService.tasks.filter { $0.isCompleted }.count
    }
    
    var storageUsed: String {
        let tasksData = (try? JSONEncoder().encode(dataService.tasks))?.count ?? 0
        let notesData = (try? JSONEncoder().encode(dataService.notes))?.count ?? 0
        let totalBytes = tasksData + notesData
        
        if totalBytes < 1024 {
            return "\(totalBytes) bytes"
        } else if totalBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(totalBytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(totalBytes) / (1024.0 * 1024.0))
        }
    }
}

extension DateFormatter {
    static let exportFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
