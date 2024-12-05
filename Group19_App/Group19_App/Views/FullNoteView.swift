//
//  FullNoteView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//



import SwiftUI


// To Add Meal Planner Notes
struct FullNoteView: View {
    let note: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(note)
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .navigationTitle("Note Details")
        }
    }
}
