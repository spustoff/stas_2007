//
//  AddNoteView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct AddNoteView: View {
    @ObservedObject var noteViewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var content = ""
    @State private var category: NoteCategory = .general
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details").foregroundColor(AppColors.accentYellow)) {
                    TextField("Note title", text: $title)
                        .foregroundColor(AppColors.primaryText)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Section(header: Text("Category").foregroundColor(AppColors.accentYellow)) {
                    Picker("Category", selection: $category) {
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
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.secondaryText),
                trailing: Button("Save") {
                    saveNote()
                }
                .foregroundColor(AppColors.accentYellow)
                .disabled(title.isEmpty)
            )
        }
    }
    
    private func saveNote() {
        noteViewModel.addNote(
            title: title,
            content: content,
            category: category
        )
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddNoteView(noteViewModel: NoteViewModel())
}
