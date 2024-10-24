//
//  FilterButtonPageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//

import SwiftUI

struct FilterButtonPageView: View {
    @Binding var meals: [Meal]        // Meals list passed as a binding to apply filtering
    @Binding var filteredMeals: [Meal] // List of filtered meals passed as a binding
    @State private var filteredSavedMeals: [Meal] = []
    @Binding var selectedCategory: String
    @Binding var selectedArea: String
    @Binding var selectedTag: String

    var onApply: () -> Void  // Callback to apply the filters and navigate back
    var onClear: () -> Void  // Callback to clear the filters

    // Get distinct categories, areas, and tags from meals
    var categories: [String] {
        var categories = meals.map { $0.strCategory }
        categories.append("All")
        return Array(Set(categories))
    }
    
    var areas: [String] {
        var areas = meals.map { $0.strArea }
        areas.append("All")
        return Array(Set(areas))
    }
    
    var tags: [String] {
        var tags = meals.compactMap { $0.strTags }
            .flatMap { $0.split(separator: ",").map { String($0) } }
        tags.append("All")
        return Array(Set(tags))
    }
    
    var body: some View {
        VStack {
            // Category Filter
            Text("Filter by Category")
                .font(.headline)
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())

            // Area Filter
            Text("Filter by Area")
                .font(.headline)
            Picker("Area", selection: $selectedArea) {
                ForEach(areas, id: \.self) { area in
                    Text(area).tag(area)
                }
            }
            .pickerStyle(MenuPickerStyle())

            // Tags Filter
            Text("Filter by Tags")
                .font(.headline)
            Picker("Tags", selection: $selectedTag) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag).tag(tag)
                }
            }
            .pickerStyle(MenuPickerStyle())

            // Apply Button
            Button(action: {
                onApply()  // Call the apply filters function
            }) {
                Text("Apply Filters")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            // Clear Filter Button
            Button(action: {
                onClear()  // Clear filters
            }) {
                Text("Clear Filters")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Filters")
    }
}
