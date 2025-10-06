//
//  NoteListView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct NoteListView: View {
    @StateObject private var noteViewModel = NoteViewModel()
    @State private var showingAddNote = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filter Bar
                if noteViewModel.selectedCategory != nil || noteViewModel.showFavoritesOnly {
                    filterBar
                }
                
                // Note List
                noteList
            }
            .background(
                LinearGradient(
                    colors: [AppColors.primaryBackground, AppColors.primaryBackground.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button(action: { showingFilters = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(AppColors.accentYellow)
                },
                trailing: Button(action: { showingAddNote = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.accentYellow)
                }
            )
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(noteViewModel: noteViewModel)
        }
        .sheet(isPresented: $showingFilters) {
            NoteFiltersView(noteViewModel: noteViewModel)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.secondaryText)
            
            TextField("Search notes...", text: $noteViewModel.searchText)
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
                if let category = noteViewModel.selectedCategory {
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: Color(category.color)
                    ) {
                        noteViewModel.selectedCategory = nil
                    }
                }
                
                if noteViewModel.showFavoritesOnly {
                    FilterChip(
                        title: "Favorites",
                        icon: "heart.fill",
                        color: AppColors.errorRed
                    ) {
                        noteViewModel.showFavoritesOnly = false
                    }
                }
                
                Button("Clear All") {
                    noteViewModel.clearFilters()
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
    
    private var noteList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(noteViewModel.filteredNotes) { note in
                    NavigationLink(destination: NoteDetailView(note: note, noteViewModel: noteViewModel)) {
                        NoteRowView(note: note, noteViewModel: noteViewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

struct NoteRowView: View {
    let note: Note
    @ObservedObject var noteViewModel: NoteViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: note.category.icon)
                .font(.title2)
                .foregroundColor(Color(note.category.color))
                .frame(width: 24)
            
            // Note Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title)
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if note.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.errorRed)
                    }
                }
                
                Text(note.content)
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                HStack {
                    // Category
                    Text(note.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(note.category.color).opacity(0.3))
                        .foregroundColor(Color(note.category.color))
                        .cornerRadius(6)
                    
                    // Tags
                    if !note.tags.isEmpty {
                        Text(note.tags.prefix(2).joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(AppColors.tertiaryText)
                        
                        if note.tags.count > 2 {
                            Text("+\(note.tags.count - 2)")
                                .font(.caption2)
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                    
                    Spacer()
                    
                    // Modified Date
                    Text(note.modifiedDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.tertiaryText)
        }
        .padding()
        .glassmorphism()
    }
}

#Preview {
    NoteListView()
}
