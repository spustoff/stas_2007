//
//  NoteViewModel.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import Combine

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var filteredNotes: [Note] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: NoteCategory?
    @Published var showFavoritesOnly: Bool = false
    @Published var sortOption: NoteSortOption = .modifiedDate
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadNotes()
    }
    
    private func setupBindings() {
        // Observe data service notes
        dataService.$notes
            .assign(to: \.notes, on: self)
            .store(in: &cancellables)
        
        // Observe changes and update filtered notes
        Publishers.CombineLatest4(
            $notes,
            $searchText,
            $selectedCategory,
            $showFavoritesOnly
        )
        .combineLatest($sortOption)
        .map { (notesAndFilters, sort) in
            let (notes, searchText, category, favoritesOnly) = notesAndFilters
            return self.filterAndSortNotes(
                notes: notes,
                searchText: searchText,
                category: category,
                favoritesOnly: favoritesOnly,
                sortOption: sort
            )
        }
        .assign(to: \.filteredNotes, on: self)
        .store(in: &cancellables)
    }
    
    private func loadNotes() {
        dataService.loadData()
    }
    
    // MARK: - Note Operations
    
    func addNote(title: String, content: String = "", category: NoteCategory = .general) {
        let newNote = Note(title: title, content: content, category: category)
        dataService.addNote(newNote)
    }
    
    func updateNote(_ note: Note) {
        dataService.updateNote(note)
    }
    
    func deleteNote(_ note: Note) {
        dataService.deleteNote(note)
    }
    
    func toggleNoteFavorite(_ note: Note) {
        dataService.toggleNoteFavorite(note)
    }
    
    func updateNoteContent(_ note: Note, newContent: String) {
        var updatedNote = note
        updatedNote.updateContent(newContent)
        dataService.updateNote(updatedNote)
    }
    
    func updateNoteTitle(_ note: Note, newTitle: String) {
        var updatedNote = note
        updatedNote.updateTitle(newTitle)
        dataService.updateNote(updatedNote)
    }
    
    // MARK: - Filtering and Sorting
    
    private func filterAndSortNotes(
        notes: [Note],
        searchText: String,
        category: NoteCategory?,
        favoritesOnly: Bool,
        sortOption: NoteSortOption
    ) -> [Note] {
        var filtered = notes
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by category
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by favorites
        if favoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // Sort notes
        return sortNotes(filtered, by: sortOption)
    }
    
    private func sortNotes(_ notes: [Note], by option: NoteSortOption) -> [Note] {
        switch option {
        case .title:
            return notes.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .createdDate:
            return notes.sorted { $0.createdDate > $1.createdDate }
        case .modifiedDate:
            return notes.sorted { $0.modifiedDate > $1.modifiedDate }
        case .category:
            return notes.sorted { $0.category.rawValue.localizedCaseInsensitiveCompare($1.category.rawValue) == .orderedAscending }
        }
    }
    
    // MARK: - Computed Properties
    
    var totalNotesCount: Int {
        notes.count
    }
    
    var favoriteNotesCount: Int {
        notes.filter { $0.isFavorite }.count
    }
    
    var notesByCategory: [NoteCategory: [Note]] {
        Dictionary(grouping: notes) { $0.category }
    }
    
    var recentNotes: [Note] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return notes.filter { $0.modifiedDate >= sevenDaysAgo }
            .sorted { $0.modifiedDate > $1.modifiedDate }
    }
    
    // MARK: - Tag Management
    
    func addTagToNote(_ note: Note, tag: String) {
        var updatedNote = note
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedTag.isEmpty && !updatedNote.tags.contains(trimmedTag) && updatedNote.tags.count < Constants.Limits.maxTagsPerNote {
            updatedNote.tags.append(trimmedTag)
            updatedNote.modifiedDate = Date()
            dataService.updateNote(updatedNote)
        }
    }
    
    func removeTagFromNote(_ note: Note, tag: String) {
        var updatedNote = note
        updatedNote.tags.removeAll { $0 == tag }
        updatedNote.modifiedDate = Date()
        dataService.updateNote(updatedNote)
    }
    
    var allTags: [String] {
        let allTags = notes.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }
    
    // MARK: - Utility Methods
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        showFavoritesOnly = false
    }
    
    func getNotesByCategory(_ category: NoteCategory) -> [Note] {
        return notes.filter { $0.category == category }
    }
    
    func searchNotesByTag(_ tag: String) -> [Note] {
        return notes.filter { $0.tags.contains(tag) }
    }
    
    func getLinkedNotes(for taskId: UUID) -> [Note] {
        return notes.filter { $0.linkedTaskIds.contains(taskId) }
    }
}

enum NoteSortOption: String, CaseIterable {
    case title = "Title"
    case createdDate = "Created Date"
    case modifiedDate = "Modified Date"
    case category = "Category"
    
    var icon: String {
        switch self {
        case .title: return "textformat.abc"
        case .createdDate: return "clock"
        case .modifiedDate: return "clock.arrow.circlepath"
        case .category: return "folder"
        }
    }
}
