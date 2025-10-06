//
//  Constants.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Constants {
    // App Information
    static let appName = "ChronoRoad Note"
    static let appVersion = "1.0.0"
    
    // UserDefaults Keys
    struct UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isDarkModeEnabled = "isDarkModeEnabled"
        static let notificationsEnabled = "notificationsEnabled"
        static let autoSaveEnabled = "autoSaveEnabled"
        static let defaultTaskCategory = "defaultTaskCategory"
        static let defaultNotePriority = "defaultNotePriority"
    }
    
    // Data Storage Keys
    struct StorageKeys {
        static let tasks = "stored_tasks"
        static let notes = "stored_notes"
        static let settings = "app_settings"
    }
    
    // UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 10
        static let animationDuration: Double = 0.3
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 20
        
        // Font sizes
        static let titleFontSize: CGFloat = 24
        static let headlineFontSize: CGFloat = 20
        static let bodyFontSize: CGFloat = 16
        static let captionFontSize: CGFloat = 14
    }
    
    // Limits
    struct Limits {
        static let maxTaskTitleLength = 100
        static let maxTaskDescriptionLength = 500
        static let maxNoteTitleLength = 100
        static let maxNoteContentLength = 10000
        static let maxTagsPerNote = 10
    }
    
    // Sample Data
    struct SampleData {
        static let sampleTasks = [
            "Complete project proposal",
            "Schedule team meeting",
            "Review quarterly reports",
            "Plan weekend activities",
            "Update personal portfolio"
        ]
        
        static let sampleNotes = [
            "Meeting Notes - Q4 Planning",
            "Ideas for App Improvement",
            "Personal Goals for 2024",
            "Reference: Swift Best Practices",
            "Daily Reflection"
        ]
    }
    
    // Onboarding
    struct Onboarding {
        static let totalSteps = 4
        static let stepTitles = [
            "Welcome to ChronoRoad Note",
            "Organize Your Tasks",
            "Capture Your Ideas",
            "Plan Your Days"
        ]
        
        static let stepDescriptions = [
            "Your ultimate productivity companion for managing tasks, notes, and daily planning.",
            "Create, categorize, and prioritize tasks with smart suggestions and deadline management.",
            "Take notes that auto-organize by content type and link directly to your tasks.",
            "Use the integrated calendar view to plan your days and maximize productivity."
        ]
    }
}
