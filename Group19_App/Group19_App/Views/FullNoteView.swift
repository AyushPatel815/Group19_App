//
//  FullNoteView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//



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
