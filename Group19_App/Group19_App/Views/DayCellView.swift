//
//  DayCellView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//

import SwiftUI

struct DayCellView: View {
    let date: Date
    let hasMealPlan: Bool
    let isSelected: Bool  // Indicates if this day is the selected one

    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.title3)
                .bold()
                .foregroundColor(isSelected ? .white : (hasMealPlan ? .green : .primary))  // White text for the selected day
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? Color.blue : (hasMealPlan ? Color.green.opacity(0.1) : Color.clear))  // Highlight with blue for the selected day
                .clipShape(Circle())  // Make the background circular
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)  // Circle stroke for the selected date
                )
        }
        .frame(height: 40)
    }
}

#Preview {
    DayCellView(date: Date(), hasMealPlan: true, isSelected: true)
}
