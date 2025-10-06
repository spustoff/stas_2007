//
//  HomeView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var noteViewModel = NoteViewModel()
    @State private var showingAddTask = false
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.UI.sectionSpacing) {
                    // Header Section
                    headerSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Recent Tasks
                    recentTasksSection
                    
                    // Recent Notes
                    recentNotesSection
                    
                    // Quick Actions
                    quickActionsSection
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
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskViewModel: taskViewModel)
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(noteViewModel: noteViewModel)
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(timeOfDayGreeting)")
                    .font(.title2)
                    .foregroundColor(AppColors.secondaryText)
                
                Text("Ready to be productive?")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppColors.primaryText)
            }
            
            Spacer()
            
            // Profile/Settings Button
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(AppColors.accentYellow)
            }
        }
        .padding(.horizontal)
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Tasks Today",
                value: "\(taskViewModel.todayTasksCount)",
                icon: "calendar.badge.clock",
                color: AppColors.accentYellow
            )
            
            StatCard(
                title: "Completed",
                value: "\(taskViewModel.completedTasksCount)",
                icon: "checkmark.circle.fill",
                color: AppColors.successGreen
            )
            
            StatCard(
                title: "Overdue",
                value: "\(taskViewModel.overdueTasksCount)",
                icon: "exclamationmark.triangle.fill",
                color: AppColors.errorRed
            )
            
            StatCard(
                title: "Total Notes",
                value: "\(noteViewModel.totalNotesCount)",
                icon: "note.text",
                color: AppColors.infoBlue
            )
        }
        .padding(.horizontal)
    }
    
    private var recentTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Tasks")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                NavigationLink("View All", destination: TaskListView())
                    .font(.caption)
                    .foregroundColor(AppColors.accentYellow)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(taskViewModel.filteredTasks.prefix(5))) { task in
                        NavigationLink(destination: TaskDetailView(task: task, taskViewModel: taskViewModel)) {
                            TaskCard(task: task)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var recentNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Notes")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                NavigationLink("View All", destination: NoteListView())
                    .font(.caption)
                    .foregroundColor(AppColors.accentYellow)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(noteViewModel.recentNotes.prefix(5))) { note in
                        NavigationLink(destination: NoteDetailView(note: note, noteViewModel: noteViewModel)) {
                            NoteCard(note: note)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                Button(action: { showingAddTask = true }) {
                    QuickActionButton(
                        title: "Add Task",
                        icon: "plus.circle.fill",
                        color: AppColors.accentYellow
                    )
                }
                
                Button(action: { showingAddNote = true }) {
                    QuickActionButton(
                        title: "Add Note",
                        icon: "note.text.badge.plus",
                        color: AppColors.accentGreen
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(AppColors.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphism()
    }
}

struct TaskCard: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: task.category.icon)
                    .foregroundColor(Color(task.category.color))
                
                Spacer()
                
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.successGreen)
                }
            }
            
            Text(task.title)
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(2)
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
            }
            
            HStack {
                Text(task.priority.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(task.priority.color).opacity(0.3))
                    .foregroundColor(Color(task.priority.color))
                    .cornerRadius(8)
                
                Spacer()
                
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
        }
        .frame(width: 200)
        .padding()
        .glassmorphism()
    }
}

struct NoteCard: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: note.category.icon)
                    .foregroundColor(Color(note.category.color))
                
                Spacer()
                
                if note.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(AppColors.errorRed)
                }
            }
            
            Text(note.title)
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(2)
            
            Text(note.content)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(3)
            
            HStack {
                Text(note.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(note.category.color).opacity(0.3))
                    .foregroundColor(Color(note.category.color))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(note.modifiedDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .frame(width: 200)
        .padding()
        .glassmorphism()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphism()
    }
}

#Preview {
    HomeView()
}
