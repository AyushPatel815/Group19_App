//
//  FullNoteView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//

//import SwiftUI
//
//struct FullNoteView: View {
//    @Binding var notes: [String]  // Binding to the notes array
//    let note: String
//    @Environment(\.dismiss) var dismiss  // To dismiss the view
//    
//    var body: some View {
//        VStack {
//            ScrollView {
//                Text(note)
//                    .font(.body)
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//        }
//        .navigationTitle("Note")
//        .toolbar {
//            // Add a delete button on the top right
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: deleteNote) {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
//            }
//        }
//    }
//
//    // Function to delete the note
//    func deleteNote() {
//        if let index = notes.firstIndex(of: note) {
//            notes.remove(at: index)
//            dismiss()  // Return to the CalendarView after deletion
//        }
//    }
//}



import SwiftUI

struct FullNoteView: View {
    let note: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(note)
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.gray.opacity(0.1))
                
                Spacer()
            }
            .navigationTitle("Note Details")
        }
    }
}
