//
//  TaskListView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filter Bar
                if taskViewModel.selectedCategory != nil || taskViewModel.selectedPriority != nil || !taskViewModel.showCompletedTasks {
                    filterBar
                }
                
                // Task List
                taskList
            }
            .background(
                LinearGradient(
                    colors: [AppColors.primaryBackground, AppColors.primaryBackground.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button(action: { showingFilters = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(AppColors.accentYellow)
                },
                trailing: Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.accentYellow)
                }
            )
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskViewModel: taskViewModel)
        }
        .sheet(isPresented: $showingFilters) {
            TaskFiltersView(taskViewModel: taskViewModel)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.secondaryText)
            
            TextField("Search tasks...", text: $taskViewModel.searchText)
                .foregroundColor(AppColors.primaryText)
        }
        .padding()
        .background(AppColors.glassBackground)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = taskViewModel.selectedCategory {
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: Color(category.color)
                    ) {
                        taskViewModel.selectedCategory = nil
                    }
                }
                
                if let priority = taskViewModel.selectedPriority {
                    FilterChip(
                        title: priority.rawValue,
                        icon: "exclamationmark.triangle",
                        color: Color(priority.color)
                    ) {
                        taskViewModel.selectedPriority = nil
                    }
                }
                
                if !taskViewModel.showCompletedTasks {
                    FilterChip(
                        title: "Hide Completed",
                        icon: "eye.slash",
                        color: AppColors.secondaryText
                    ) {
                        taskViewModel.showCompletedTasks = true
                    }
                }
                
                Button("Clear All") {
                    taskViewModel.clearFilters()
                }
                .font(.caption)
                .foregroundColor(AppColors.accentYellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.glassBackground)
                .cornerRadius(16)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(taskViewModel.filteredTasks) { task in
                    NavigationLink(destination: TaskDetailView(task: task, taskViewModel: taskViewModel)) {
                        TaskRowView(task: task, taskViewModel: taskViewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var taskViewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: { taskViewModel.toggleTaskCompletion(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? AppColors.successGreen : AppColors.secondaryText)
            }
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                }
                
                HStack {
                    // Category
                    HStack(spacing: 4) {
                        Image(systemName: task.category.icon)
                            .font(.caption)
                        Text(task.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(Color(task.category.color))
                    
                    // Priority
                    Text(task.priority.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(task.priority.color).opacity(0.3))
                        .foregroundColor(Color(task.priority.color))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    // Due Date
                    if let dueDate = task.dueDate {
                        Text(dueDate, style: .date)
                            .font(.caption2)
                            .foregroundColor(dueDate < Date() && !task.isCompleted ? AppColors.errorRed : AppColors.tertiaryText)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.tertiaryText)
        }
        .padding()
        .glassmorphism()
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    TaskListView()
}
