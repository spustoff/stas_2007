//
//  SettingsView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.UI.sectionSpacing) {
                    // App Info Section
                    appInfoSection
                    
                    // Preferences Section
                    preferencesSection
                    
                    // Statistics Section
                    statisticsSection
                    
                    // Data Management Section
                    dataManagementSection
                    
                    // About Section
                    aboutSection
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(AppColors.primaryText)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.accentYellow)
            )
        }
        .sheet(isPresented: $settingsViewModel.showAboutSheet) {
            AboutView()
        }
        .alert("Reset App Data", isPresented: $settingsViewModel.showResetConfirmation) {
            Button("Reset", role: .destructive) {
                settingsViewModel.resetApp()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all your tasks, notes, and settings. This action cannot be undone.")
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            // App Icon and Name
            VStack(spacing: 8) {
                Image(systemName: "note.text.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.accentYellow)
                
                Text(Constants.appName)
                    .font(.title2.bold())
                    .foregroundColor(AppColors.primaryText)
                
                Text("Version \(settingsViewModel.appVersion) (\(settingsViewModel.buildNumber))")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphism()
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 12) {
                // Dark Mode Toggle
                
                Divider()
                    .background(AppColors.glassStroke)
                
                // Auto Save Toggle
                SettingsRow(
                    icon: "square.and.arrow.down.fill",
                    title: "Auto Save",
                    subtitle: "Automatically save changes"
                ) {
                    Toggle("", isOn: $settingsViewModel.autoSaveEnabled)
                        .tint(AppColors.accentYellow)
                }
                
                Divider()
                    .background(AppColors.glassStroke)
                
                // Default Task Category
                SettingsRow(
                    icon: "folder.fill",
                    title: "Default Task Category",
                    subtitle: "Category for new tasks"
                ) {
                    Picker("", selection: $settingsViewModel.defaultTaskCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(AppColors.accentYellow)
                }
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatisticCard(
                    title: "Total Tasks",
                    value: "\(settingsViewModel.totalTasks)",
                    icon: "checkmark.circle.fill",
                    color: AppColors.accentYellow
                )
                
                StatisticCard(
                    title: "Completed",
                    value: "\(settingsViewModel.completedTasks)",
                    icon: "checkmark.circle.fill",
                    color: AppColors.successGreen
                )
                
                StatisticCard(
                    title: "Total Notes",
                    value: "\(settingsViewModel.totalNotes)",
                    icon: "note.text",
                    color: AppColors.infoBlue
                )
                
                StatisticCard(
                    title: "Storage Used",
                    value: settingsViewModel.storageUsed,
                    icon: "internaldrive.fill",
                    color: AppColors.warningYellow
                )
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 12) {
                // Export Data Button
                // Reset App Button
                Button(action: {
                    settingsViewModel.showResetConfirmation = true
                }) {
                    SettingsActionRow(
                        icon: "trash.fill",
                        title: "Reset App",
                        subtitle: "Delete all data and settings",
                        color: AppColors.errorRed
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 12) {
                Button(action: {
                    settingsViewModel.showAboutSheet = true
                }) {
                    SettingsActionRow(
                        icon: "info.circle.fill",
                        title: "About ChronoRoad Note",
                        subtitle: "Learn more about the app",
                        color: AppColors.accentYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .glassmorphism()
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.accentYellow)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            content
        }
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.tertiaryText)
        }
    }
}

struct StatisticCard: View {
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
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.glassBackground)
        .cornerRadius(12)
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "note.text.badge.plus")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.accentYellow)
                    
                Text(Constants.appName)
                .font(.largeTitle.bold())
                .foregroundColor(AppColors.primaryText)
                    
                    Text("Your ultimate productivity companion for managing tasks, notes, and daily planning.")
                        .font(.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "checkmark.circle.fill", title: "Smart Task Management", description: "Create, categorize, and prioritize tasks with intelligent suggestions.")
                        
                        FeatureRow(icon: "note.text", title: "Dynamic Notes", description: "Auto-organizing notes that link directly to your tasks.")
                        
                        FeatureRow(icon: "calendar", title: "Daily Planning", description: "Integrated calendar view for maximum productivity.")
                        
                        FeatureRow(icon: "magnifyingglass", title: "Reference Library", description: "Quick access to all your important information.")
                    }
                    .padding()
                    .glassmorphism()
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
            .navigationTitle("About")
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.accentYellow)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
}

#Preview {
    SettingsView()
}
