//
//  NoteDetailView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct NoteDetailView: View {
    @State var note: Note
    @ObservedObject var noteViewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedContent = ""
    @State private var editedCategory: NoteCategory = .general
    @State private var newTag = ""
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.UI.sectionSpacing) {
                // Header Section
                headerSection
                
                // Note Content
                noteContentSection
                
                // Tags Section
                tagsSection
                
                // Linked Tasks Section
                linkedTasksSection
                
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
            trailing: HStack {
                Button(action: { noteViewModel.toggleNoteFavorite(note) }) {
                    Image(systemName: note.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(note.isFavorite ? AppColors.errorRed : AppColors.secondaryText)
                }
                
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }
                .foregroundColor(AppColors.accentYellow)
            }
        )
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: note.category.icon)
                    .font(.title)
                    .foregroundColor(Color(note.category.color))
                
                VStack(alignment: .leading) {
                    if isEditing {
                        TextField("Note title", text: $editedTitle)
                            .font(.title2.bold())
                            .foregroundColor(AppColors.primaryText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(note.title)
                            .font(.title2.bold())
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Created \(note.createdDate, formatter: DateFormatter.noteFormatter)")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        if note.modifiedDate != note.createdDate {
                            Text("Modified \(note.modifiedDate, formatter: DateFormatter.noteFormatter)")
                                .font(.caption)
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                }
                
                Spacer()
                
                if note.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.errorRed)
                }
            }
            
            // Category Picker (when editing)
            if isEditing {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Picker("Category", selection: $editedCategory) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
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
            } else {
                HStack {
                    Text(note.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(note.category.color).opacity(0.3))
                        .foregroundColor(Color(note.category.color))
                        .cornerRadius(12)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var noteContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            if isEditing {
                TextEditor(text: $editedContent)
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(AppColors.glassBackground)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.primaryText)
            } else {
                ScrollView {
                    Text(note.content.isEmpty ? "No content" : note.content)
                        .foregroundColor(note.content.isEmpty ? AppColors.tertiaryText : AppColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(minHeight: 100)
                .background(AppColors.glassBackground)
                .cornerRadius(8)
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            if isEditing {
                HStack {
                    TextField("Add tag", text: $newTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        if !newTag.isEmpty {
                            noteViewModel.addTagToNote(note, tag: newTag)
                            newTag = ""
                            // Update local note
                            if let updatedNote = noteViewModel.notes.first(where: { $0.id == note.id }) {
                                note = updatedNote
                            }
                        }
                    }
                    .foregroundColor(AppColors.accentYellow)
                    .disabled(newTag.isEmpty)
                }
            }
            
            if note.tags.isEmpty {
                Text("No tags")
                    .foregroundColor(AppColors.tertiaryText)
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], spacing: 8) {
                    ForEach(note.tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(AppColors.primaryText)
                            
                            if isEditing {
                                Button(action: {
                                    noteViewModel.removeTagFromNote(note, tag: tag)
                                    // Update local note
                                    if let updatedNote = noteViewModel.notes.first(where: { $0.id == note.id }) {
                                        note = updatedNote
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(AppColors.errorRed)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.accentYellow.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var linkedTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Linked Tasks")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            if note.linkedTaskIds.isEmpty {
                Text("No linked tasks")
                    .foregroundColor(AppColors.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Note: In a real implementation, you would fetch the actual tasks
                // For now, we'll show placeholder
                Text("\(note.linkedTaskIds.count) linked task(s)")
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: { noteViewModel.toggleNoteFavorite(note) }) {
                HStack {
                    Image(systemName: note.isFavorite ? "heart.slash" : "heart.fill")
                    Text(note.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(note.isFavorite ? AppColors.warningYellow : AppColors.errorRed)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: { showingDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Note")
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
        editedTitle = note.title
        editedContent = note.content
        editedCategory = note.category
        isEditing = true
    }
    
    private func saveChanges() {
        var updatedNote = note
        updatedNote.title = editedTitle
        updatedNote.content = editedContent
        updatedNote.category = editedCategory
        updatedNote.modifiedDate = Date()
        
        noteViewModel.updateNote(updatedNote)
        note = updatedNote
        isEditing = false
    }
    
    private func deleteNote() {
        noteViewModel.deleteNote(note)
        presentationMode.wrappedValue.dismiss()
    }
}

extension DateFormatter {
    static let noteFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    NavigationView {
        NoteDetailView(
            note: Note(title: "Sample Note", content: "This is a sample note content with some text to demonstrate the layout.", category: .ideas),
            noteViewModel: NoteViewModel()
        )
    }
}
