//
//  TaskFiltersView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct TaskFiltersView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category").foregroundColor(AppColors.accentYellow)) {
                    Picker("Category", selection: $taskViewModel.selectedCategory) {
                        Text("All Categories")
                            .tag(nil as TaskCategory?)
                        
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category as TaskCategory?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(AppColors.primaryText)
                }
                
                Section(header: Text("Priority").foregroundColor(AppColors.accentYellow)) {
                    Picker("Priority", selection: $taskViewModel.selectedPriority) {
                        Text("All Priorities")
                            .tag(nil as TaskPriority?)
                        
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                                .tag(priority as TaskPriority?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(AppColors.primaryText)
                }
                
                Section(header: Text("Completion Status").foregroundColor(AppColors.accentYellow)) {
                    Toggle("Show completed tasks", isOn: $taskViewModel.showCompletedTasks)
                        .foregroundColor(AppColors.primaryText)
                        .tint(AppColors.accentYellow)
                }
                
                Section(header: Text("Sort By").foregroundColor(AppColors.accentYellow)) {
                    Picker("Sort by", selection: $taskViewModel.sortOption) {
                        ForEach(TaskSortOption.allCases, id: \.self) { option in
                            HStack {
                                Image(systemName: option.icon)
                                Text(option.rawValue)
                            }
                            .tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(AppColors.primaryText)
                }
                
                Section {
                    Button("Clear All Filters") {
                        taskViewModel.clearFilters()
                    }
                    .foregroundColor(AppColors.accentYellow)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Filter Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.accentYellow)
            )
        }
    }
}

#Preview {
    TaskFiltersView(taskViewModel: TaskViewModel())
}
