//
//  DataService.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var tasks: [Task] = []
    @Published var notes: [Note] = []
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Loading and Saving
    
    func loadData() {
        loadTasks()
        loadNotes()
    }
    
    func saveData() {
        saveTasks()
        saveNotes()
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: Constants.StorageKeys.tasks),
           let decodedTasks = try? decoder.decode([Task].self, from: data) {
            self.tasks = decodedTasks
        } else {
            // Create sample tasks for first launch
            createSampleTasks()
        }
    }
    
    private func saveTasks() {
        if let encoded = try? encoder.encode(tasks) {
            userDefaults.set(encoded, forKey: Constants.StorageKeys.tasks)
        }
    }
    
    private func loadNotes() {
        if let data = userDefaults.data(forKey: Constants.StorageKeys.notes),
           let decodedNotes = try? decoder.decode([Note].self, from: data) {
            self.notes = decodedNotes
        } else {
            // Create sample notes for first launch
            createSampleNotes()
        }
    }
    
    private func saveNotes() {
        if let encoded = try? encoder.encode(notes) {
            userDefaults.set(encoded, forKey: Constants.StorageKeys.notes)
        }
    }
    
    // MARK: - Task Operations
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].completedDate = tasks[index].isCompleted ? Date() : nil
            saveTasks()
        }
    }
    
    // MARK: - Note Operations
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func toggleNoteFavorite(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isFavorite.toggle()
            saveNotes()
        }
    }
    
    // MARK: - Filtering and Searching
    
    func getTasksByCategory(_ category: TaskCategory) -> [Task] {
        return tasks.filter { $0.category == category }
    }
    
    func getTasksByPriority(_ priority: TaskPriority) -> [Task] {
        return tasks.filter { $0.priority == priority }
    }
    
    func getCompletedTasks() -> [Task] {
        return tasks.filter { $0.isCompleted }
    }
    
    func getPendingTasks() -> [Task] {
        return tasks.filter { !$0.isCompleted }
    }
    
    func getOverdueTasks() -> [Task] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return !task.isCompleted && dueDate < now
        }
    }
    
    func getNotesByCategory(_ category: NoteCategory) -> [Note] {
        return notes.filter { $0.category == category }
    }
    
    func getFavoriteNotes() -> [Note] {
        return notes.filter { $0.isFavorite }
    }
    
    func searchTasks(_ query: String) -> [Task] {
        guard !query.isEmpty else { return tasks }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(query) ||
            task.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func searchNotes(_ query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query) ||
            note.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    // MARK: - Linking Tasks and Notes
    
    func linkTaskToNote(taskId: UUID, noteId: UUID) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == taskId }) {
            if !tasks[taskIndex].linkedNoteIds.contains(noteId) {
                tasks[taskIndex].linkedNoteIds.append(noteId)
            }
        }
        
        if let noteIndex = notes.firstIndex(where: { $0.id == noteId }) {
            if !notes[noteIndex].linkedTaskIds.contains(taskId) {
                notes[noteIndex].linkedTaskIds.append(taskId)
            }
        }
        
        saveData()
    }
    
    func unlinkTaskFromNote(taskId: UUID, noteId: UUID) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[taskIndex].linkedNoteIds.removeAll { $0 == noteId }
        }
        
        if let noteIndex = notes.firstIndex(where: { $0.id == noteId }) {
            notes[noteIndex].linkedTaskIds.removeAll { $0 == taskId }
        }
        
        saveData()
    }
    
    // MARK: - Data Reset
    
    func resetAllData() {
        tasks.removeAll()
        notes.removeAll()
        userDefaults.removeObject(forKey: Constants.StorageKeys.tasks)
        userDefaults.removeObject(forKey: Constants.StorageKeys.notes)
        userDefaults.removeObject(forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
        
        // Recreate sample data
        createSampleTasks()
        createSampleNotes()
    }
    
    // MARK: - Sample Data Creation
    
    private func createSampleTasks() {
        let sampleTasks = [
            Task(title: "Complete project proposal", description: "Finish the Q4 project proposal for the new mobile app", category: .work, priority: .high, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())),
            Task(title: "Schedule team meeting", description: "Organize weekly team sync meeting", category: .work, priority: .medium, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())),
            Task(title: "Plan weekend activities", description: "Research and plan fun activities for the weekend", category: .personal, priority: .low, dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())),
            Task(title: "Update personal portfolio", description: "Add recent projects and update resume", category: .personal, priority: .medium),
            Task(title: "Learn SwiftUI animations", description: "Complete the advanced SwiftUI animations course", category: .learning, priority: .medium)
        ]
        
        self.tasks = sampleTasks
        saveTasks()
    }
    
    private func createSampleNotes() {
        let sampleNotes = [
            Note(title: "Meeting Notes - Q4 Planning", content: "Discussed upcoming projects, resource allocation, and timeline for Q4 deliverables. Key points: increase team size, focus on mobile-first approach, implement new design system.", category: .meeting),
            Note(title: "Ideas for App Improvement", content: "1. Add dark mode support\n2. Implement push notifications\n3. Create widget for iOS home screen\n4. Add collaboration features\n5. Integrate with calendar apps", category: .ideas),
            Note(title: "Personal Goals for 2024", content: "Career: Get promoted to senior developer\nHealth: Exercise 3x per week\nLearning: Master SwiftUI and Combine\nPersonal: Travel to Japan\nFinance: Save 20% of income", category: .personal),
            Note(title: "Reference: Swift Best Practices", content: "- Use meaningful variable names\n- Follow SOLID principles\n- Implement proper error handling\n- Write unit tests\n- Use dependency injection\n- Keep functions small and focused", category: .reference),
            Note(title: "Daily Reflection", content: "Today was productive. Completed the main features for the task management app. Need to focus more on UI polish tomorrow. Feeling good about the progress.", category: .general)
        ]
        
        self.notes = sampleNotes
        saveNotes()
    }
}
