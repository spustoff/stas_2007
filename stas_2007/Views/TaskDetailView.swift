//
//  TaskDetailView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct TaskDetailView: View {
    @State var task: Task
    @ObservedObject var taskViewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    @State private var editedCategory: TaskCategory = .personal
    @State private var editedPriority: TaskPriority = .medium
    @State private var editedDueDate: Date = Date()
    @State private var hasDueDate = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.UI.sectionSpacing) {
                // Header Section
                headerSection
                
                // Task Details
                taskDetailsSection
                
                // Linked Notes Section
                linkedNotesSection
                
                // Action Buttons
                actionButtonsSection
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [AppColors.primaryBackground, AppColors.primaryBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(isEditing ? "Save" : "Edit") {
                if isEditing {
                    saveChanges()
                } else {
                    startEditing()
                }
            }
            .foregroundColor(AppColors.accentYellow)
        )
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: task.category.icon)
                    .font(.title)
                    .foregroundColor(Color(task.category.color))
                
                VStack(alignment: .leading) {
                    if isEditing {
                        TextField("Task title", text: $editedTitle)
                            .font(.title2.bold())
                            .foregroundColor(AppColors.primaryText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(task.title)
                            .font(.title2.bold())
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Text("Created \(task.createdDate, formatter: DateFormatter.taskFormatter)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Button(action: { taskViewModel.toggleTaskCompletion(task) }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(task.isCompleted ? AppColors.successGreen : AppColors.secondaryText)
                }
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                if isEditing {
                    TextEditor(text: $editedDescription)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(AppColors.glassBackground)
                        .cornerRadius(8)
                        .foregroundColor(AppColors.primaryText)
                } else {
                    Text(task.description.isEmpty ? "No description" : task.description)
                        .foregroundColor(task.description.isEmpty ? AppColors.tertiaryText : AppColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Category
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                if isEditing {
                    Picker("Category", selection: $editedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(AppColors.primaryText)
                } else {
                    HStack {
                        Image(systemName: task.category.icon)
                            .foregroundColor(Color(task.category.color))
                        Text(task.category.rawValue)
                            .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            
            // Priority
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                if isEditing {
                    Picker("Priority", selection: $editedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } else {
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(task.priority.color).opacity(0.3))
                        .foregroundColor(Color(task.priority.color))
                        .cornerRadius(12)
                }
            }
            
            // Due Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Due Date")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                if isEditing {
                    Toggle("Has due date", isOn: $hasDueDate)
                        .foregroundColor(AppColors.primaryText)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $editedDueDate, displayedComponents: [.date, .hourAndMinute])
                            .foregroundColor(AppColors.primaryText)
                    }
                } else {
                    if let dueDate = task.dueDate {
                        Text(dueDate, formatter: DateFormatter.taskFormatter)
                            .foregroundColor(AppColors.primaryText)
                    } else {
                        Text("No due date")
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
            
            // Completion Status
            if task.isCompleted, let completedDate = task.completedDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completed")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(completedDate, formatter: DateFormatter.taskFormatter)
                        .foregroundColor(AppColors.successGreen)
                }
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var linkedNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Linked Notes")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            if task.linkedNoteIds.isEmpty {
                Text("No linked notes")
                    .foregroundColor(AppColors.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Note: In a real implementation, you would fetch the actual notes
                // For now, we'll show placeholder
                Text("\(task.linkedNoteIds.count) linked note(s)")
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: { taskViewModel.toggleTaskCompletion(task) }) {
                HStack {
                    Image(systemName: task.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle")
                    Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(task.isCompleted ? AppColors.warningYellow : AppColors.successGreen)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: { showingDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Task")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.errorRed)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func startEditing() {
        editedTitle = task.title
        editedDescription = task.description
        editedCategory = task.category
        editedPriority = task.priority
        editedDueDate = task.dueDate ?? Date()
        hasDueDate = task.dueDate != nil
        isEditing = true
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.title = editedTitle
        updatedTask.description = editedDescription
        updatedTask.category = editedCategory
        updatedTask.priority = editedPriority
        updatedTask.dueDate = hasDueDate ? editedDueDate : nil
        
        taskViewModel.updateTask(updatedTask)
        task = updatedTask
        isEditing = false
    }
    
    private func deleteTask() {
        taskViewModel.deleteTask(task)
        presentationMode.wrappedValue.dismiss()
    }
}

extension DateFormatter {
    static let taskFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    NavigationView {
        TaskDetailView(
            task: Task(title: "Sample Task", description: "This is a sample task description", category: .work, priority: .high),
            taskViewModel: TaskViewModel()
        )
    }
}
