//
//  NoteFiltersView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct NoteFiltersView: View {
    @ObservedObject var noteViewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category").foregroundColor(AppColors.accentYellow)) {
                    Picker("Category", selection: $noteViewModel.selectedCategory) {
                        Text("All Categories")
                            .tag(nil as NoteCategory?)
                        
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category as NoteCategory?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(AppColors.primaryText)
                }
                
                Section(header: Text("Favorites").foregroundColor(AppColors.accentYellow)) {
                    Toggle("Show favorites only", isOn: $noteViewModel.showFavoritesOnly)
                        .foregroundColor(AppColors.primaryText)
                        .tint(AppColors.accentYellow)
                }
                
                Section(header: Text("Sort By").foregroundColor(AppColors.accentYellow)) {
                    Picker("Sort by", selection: $noteViewModel.sortOption) {
                        ForEach(NoteSortOption.allCases, id: \.self) { option in
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
                        noteViewModel.clearFilters()
                    }
                    .foregroundColor(AppColors.accentYellow)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Filter Notes")
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
    NoteFiltersView(noteViewModel: NoteViewModel())
}
