//
//  MealSectionView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//

//import SwiftUI
//
//struct MealSectionView: View {
//    let mealType: String
//    let notes: [String]
//    let editAction: () -> EditNotesView
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text("\(mealType)")
//                    .font(.title2)
//                    .bold()
//                Spacer()
//                NavigationLink(destination: editAction()) {
//                    Text("Add Notes")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                }
//            }
//
//            // Display notes as scrollable items
//            if notes.isEmpty {
//                Text("No notes for \(mealType)")
//                    .foregroundColor(.gray)
//                    .padding(.vertical, 5)
//            } else {
//                ForEach(notes, id: \.self) { note in
//                    NavigationLink(destination: FullNoteView(note: note)) {
//                        Text(note)
//                            .font(.body)
//                            .foregroundColor(.black)
//                            .padding(.vertical, 5)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    }
//                }
//            }
//
//            Divider()
//        }
//        .padding()
//    }
//}




//import SwiftUI
//
//struct MealSectionView: View {
//    let mealType: String
//    @Binding var notes: [String]  // Binding to the notes array for this meal type
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text(mealType)
//                    .font(.title2)
//                    .bold()
//                Spacer()
//                NavigationLink(destination: EditNotesView(notes: $notes)) {
//                    Text("Add Notes")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                }
//            }
//
//            // Display the notes with swipe-to-delete functionality
//            if notes.isEmpty {
//                Text("No notes for \(mealType)")
//                    .foregroundColor(.gray)
//                    .padding(.vertical, 5)
//            } else {
//                ForEach(Array(notes.enumerated()), id: \.element) { index, note in
//                    VStack {
//
//                        NavigationLink(destination: FullNoteView(notes: $notes, note: note)) {  // Pass the note and notes array as binding
//                            Text(note)
//                                .font(.body)
//                                .foregroundColor(.black)
//                                .padding(.vertical, 5)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(8)
//                                .padding(.horizontal)
//                        }
//                    }
//                    .frame(height: 60)
//                    .padding(.vertical, 5)
//                }
//            }
//
//            Divider()
//        }
//        .padding()
//    }
//
//    // Function to delete a note at the specified index
//    func deleteNote(at index: Int) {
//        notes.remove(at: index)  // Remove the note at the specified index
//    }
//}




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

//            Divider()
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

