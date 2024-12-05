//
//  FilterButtonPageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/21/24.
//


import SwiftUI

struct FilterButtonPageView: View {
    @Binding var meals: [Meal]
    @Binding var filteredMeals: [Meal]
    @Binding var selectedCategory: String
    @Binding var selectedArea: String
    @Binding var selectedTag: String
    
    var onApply: () -> Void
    var onClear: () -> Void
    
    @State private var showCategories = true // Initially expanded
    @State private var showAreas = true // Initially expanded
    @State private var showTags = true // Initially expanded
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Categories Dropdown Section
                createDropdownSection(
                    title: "Filter by Categories",
                    items: Array(Set(meals.map { $0.strCategory })).sorted(),
                    selectedItem: $selectedCategory,
                    showDropdown: $showCategories
                )
                
                // Areas Dropdown Section
                createDropdownSection(
                    title: "Filter by Areas",
                    items: Array(Set(meals.map { $0.strArea })).sorted(),
                    selectedItem: $selectedArea,
                    showDropdown: $showAreas
                )
                
                // Tags Dropdown Section
                createDropdownSection(
                    title: "Filter by Tags",
                    items: Array(Set(meals.compactMap { $0.strTags }
                        .flatMap { $0.split(separator: ",").map { String($0) } })).sorted(),
                    selectedItem: $selectedTag,
                    showDropdown: $showTags
                )
                
                // Clear Filters Button
                Button(action: {
                    selectedCategory = "All"
                    selectedArea = "All"
                    selectedTag = "All"
                    onClear()
                }) {
                    Text("Clear Filters")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            }
            .padding()
            Spacer()
                .frame(height: 30)
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline) // Ensure compact navigation bar
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func createDropdownSection(
        title: String,
        items: [String],
        selectedItem: Binding<String>,
        showDropdown: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Header
            HStack {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 5)
                Spacer()
                Button(action: {
                    showDropdown.wrappedValue.toggle()
                }) {
                    Image(systemName: showDropdown.wrappedValue ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            // Dropdown List
            if showDropdown.wrappedValue {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        CheckBoxView(isChecked: selectedItem.wrappedValue == item) {
                            selectedItem.wrappedValue = (selectedItem.wrappedValue == item ? "All" : item)
                            onApply() // Automatically apply the filter
                        }
                    }
                    .padding(.vertical, 5)
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }
}

struct CheckBoxView: View {
    var isChecked: Bool
    var onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .foregroundColor(isChecked ? .blue : .gray)
                .font(.system(size: 20))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
