//
//  MealSectionView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//


import SwiftUI

struct MealSectionView: View {
    let mealType: String
    @Binding var notes: [String]  // Binding to the notes array for this meal type
    @State private var isEditNoteViewPresented = false  // State to show the EditNotesView
    @State private var selectedNoteIndex: Int? = nil  // Track the selected note index for editing

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(mealType)
                    .font(.title2)
                    .bold()
                Spacer()
                NavigationLink(destination: EditNotesView(notes: $notes, isNewNote: true)) {
                    Text("Add Notes")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            // Display the notes with swipe-to-delete and pencil icon for editing
            if notes.isEmpty {
                Text("No notes for \(mealType)")
                    .foregroundColor(.gray)
                    .padding(.vertical, 5)
            } else {
                List {
                    ForEach(notes.indices, id: \.self) { index in
                        HStack {
                            NavigationLink(destination: FullNoteView(note: notes[index])) {
                                Text(notes[index])
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(8)
                                
                                // Pencil icon button to edit the note
                                Button(action: {
                                    selectedNoteIndex = index  // Set the selected note index
                                    isEditNoteViewPresented = true  // Present the edit view
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                        .padding(.leading, 10)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            
                            
                        }
                    }
                    .onDelete(perform: deleteNote)  // Enable swipe-to-delete
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(notes.count * 60))  // Adjust height dynamically
            }

        }
        .padding()
        .sheet(isPresented: $isEditNoteViewPresented) {
            // Pass the selected note for editing
            if let selectedIndex = selectedNoteIndex {
                EditSpecificNoteView(
                    note: $notes[selectedIndex],  // Pass the specific note binding
                    onSave: {
                        isEditNoteViewPresented = false  // Dismiss after saving
                    }
                )
            }
        }
    }

    // Function to delete a note at the specified index
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)  // Remove the note at the specified index
    }
}


struct EditSpecificNoteView: View {
    @Binding var note: String  // Binding for the specific note to edit
    var onSave: () -> Void  // Callback when saving the note

    var body: some View {
        VStack {
            Text("Edit Note")
                .font(.title)
                .padding()

            TextEditor(text: $note)  // Edit the note directly
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 150)

            Spacer()

            // Save button
            Button(action: {
                onSave()  // Call the save callback
            }) {
                Text("Save")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .padding(.bottom,75)
    }
}

