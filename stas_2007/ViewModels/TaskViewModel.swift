//
//  TaskViewModel.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: TaskCategory?
    @Published var selectedPriority: TaskPriority?
    @Published var showCompletedTasks: Bool = true
    @Published var sortOption: TaskSortOption = .dueDate
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadTasks()
    }
    
    private func setupBindings() {
        // Observe data service tasks
        dataService.$tasks
            .assign(to: \.tasks, on: self)
            .store(in: &cancellables)
        
        // Observe changes and update filtered tasks
        Publishers.CombineLatest4(
            $tasks,
            $searchText,
            $selectedCategory,
            $selectedPriority
        )
        .combineLatest($showCompletedTasks, $sortOption)
        .map { (tasksAndFilters, showCompleted, sort) in
            let (tasks, searchText, category, priority) = tasksAndFilters
            return self.filterAndSortTasks(
                tasks: tasks,
                searchText: searchText,
                category: category,
                priority: priority,
                showCompleted: showCompleted,
                sortOption: sort
            )
        }
        .assign(to: \.filteredTasks, on: self)
        .store(in: &cancellables)
    }
    
    private func loadTasks() {
        dataService.loadData()
    }
    
    // MARK: - Task Operations
    
    func addTask(title: String, description: String = "", category: TaskCategory = .personal, priority: TaskPriority = .medium, dueDate: Date? = nil) {
        let newTask = Task(title: title, description: description, category: category, priority: priority, dueDate: dueDate)
        dataService.addTask(newTask)
    }
    
    func updateTask(_ task: Task) {
        dataService.updateTask(task)
    }
    
    func deleteTask(_ task: Task) {
        dataService.deleteTask(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        dataService.toggleTaskCompletion(task)
    }
    
    // MARK: - Filtering and Sorting
    
    private func filterAndSortTasks(
        tasks: [Task],
        searchText: String,
        category: TaskCategory?,
        priority: TaskPriority?,
        showCompleted: Bool,
        sortOption: TaskSortOption
    ) -> [Task] {
        var filtered = tasks
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by priority
        if let priority = priority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Filter by completion status
        if !showCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Sort tasks
        return sortTasks(filtered, by: sortOption)
    }
    
    private func sortTasks(_ tasks: [Task], by option: TaskSortOption) -> [Task] {
        switch option {
        case .title:
            return tasks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .dueDate:
            return tasks.sorted { task1, task2 in
                guard let date1 = task1.dueDate else { return false }
                guard let date2 = task2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            return tasks.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
        case .createdDate:
            return tasks.sorted { $0.createdDate > $1.createdDate }
        case .category:
            return tasks.sorted { $0.category.rawValue.localizedCaseInsensitiveCompare($1.category.rawValue) == .orderedAscending }
        }
    }
    
    // MARK: - Computed Properties
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var overdueTasksCount: Int {
        dataService.getOverdueTasks().count
    }
    
    var todayTasksCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= today && dueDate < tomorrow && !task.isCompleted
        }.count
    }
    
    // MARK: - Utility Methods
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedPriority = nil
        showCompletedTasks = true
    }
    
    func getTasksByCategory(_ category: TaskCategory) -> [Task] {
        return tasks.filter { $0.category == category }
    }
    
    func getTasksByPriority(_ priority: TaskPriority) -> [Task] {
        return tasks.filter { $0.priority == priority }
    }
}

enum TaskSortOption: String, CaseIterable {
    case title = "Title"
    case dueDate = "Due Date"
    case priority = "Priority"
    case createdDate = "Created Date"
    case category = "Category"
    
    var icon: String {
        switch self {
        case .title: return "textformat.abc"
        case .dueDate: return "calendar"
        case .priority: return "exclamationmark.triangle"
        case .createdDate: return "clock"
        case .category: return "folder"
        }
    }
}
