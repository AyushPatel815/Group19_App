//
//  EditNotesView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//


import SwiftUI

struct EditNotesView: View {
    @Binding var notes: [String]  // Binding to hold the notes array
    @State private var newNote: String = ""  // New note input
    @Environment(\.dismiss) var dismiss  // Dismiss the view

    var isNewNote: Bool  // Flag to check if this is a new note or editing an existing one

    var body: some View {
        VStack {
            // Text editor for the new note or editing an existing note
            TextEditor(text: $newNote)
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 150)

            Spacer()

            // Save the notes and dismiss the view
            Button(action: {
                if !newNote.isEmpty {
                    if isNewNote {
                        // Add new note to the notes array
                        notes.append(newNote)
                    } else {
                        // Save changes to the existing note (if it's already in the list)
                        if let index = notes.firstIndex(where: { $0 == newNote }) {
                            notes[index] = newNote
                        }
                    }
                }
                dismiss()  // Close the view after saving
            }) {
                Text(isNewNote ? "Add Note" : "Save Changes")  // Dynamic button text based on context
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle(isNewNote ? "Add Note" : "Edit Note")  // Dynamic title based on context
        .padding()
        .padding(.bottom,75)
    }
}
