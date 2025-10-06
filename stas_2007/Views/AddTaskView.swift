//
//  AddTaskView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var category: TaskCategory = .personal
    @State private var priority: TaskPriority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").foregroundColor(AppColors.accentYellow)) {
                    TextField("Task title", text: $title)
                        .foregroundColor(AppColors.primaryText)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Section(header: Text("Category").foregroundColor(AppColors.accentYellow)) {
                    Picker("Category", selection: $category) {
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
                }
                
                Section(header: Text("Priority").foregroundColor(AppColors.accentYellow)) {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Due Date").foregroundColor(AppColors.accentYellow)) {
                    Toggle("Set due date", isOn: $hasDueDate)
                        .foregroundColor(AppColors.primaryText)
                        .tint(AppColors.accentYellow)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.secondaryText),
                trailing: Button("Save") {
                    saveTask()
                }
                .foregroundColor(AppColors.accentYellow)
                .disabled(title.isEmpty)
            )
        }
    }
    
    private func saveTask() {
        taskViewModel.addTask(
            title: title,
            description: description,
            category: category,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddTaskView(taskViewModel: TaskViewModel())
}
