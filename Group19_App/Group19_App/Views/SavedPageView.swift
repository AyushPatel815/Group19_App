//
//  SavedPageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//


//import SwiftUI
//
//struct SavedPageView: View {
//    @Binding var savedMeals: [Meal]  // Binding for saved meals
//    @Binding var meals: [Meal]  // Binding to meals from parent view
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                if savedMeals.isEmpty {
//                    Text("No saved meals yet!")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                } else {
//                    ForEach(savedMeals, id: \.idMeal) { meal in
//                        NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
//                            HStack {
//                                // Image on the left
//                                if let imageUrl = URL(string: meal.strMealThumb) {
//                                    AsyncImage(url: imageUrl) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFit()
//                                    } placeholder: {
//                                        ProgressView()
//                                    }
//                                    .frame(width: 100, height: 100)
//                                    .cornerRadius(10)
//                                }
//
//                                // Meal name on the right
//                                Text(meal.strMeal)
//                                    .font(.headline)
//                                    .foregroundColor(.black)
//                                    .multilineTextAlignment(.leading)
//                                    .padding(.leading)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                // Save Icon on the far right
//                                Button(action: {
//                                    // Remove from saved meals if already saved
//                                    if let index = savedMeals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
//                                        savedMeals.remove(at: index)
//                                    } else {
//                                        savedMeals.append(meal)
//                                    }
//                                }) {
//                                    Image(savedMeals.contains(where: { $0.idMeal == meal.idMeal }) ? "saveFill" : "save")  // Ternary operator to toggle between save and saveFill
//                                        .resizable()
//                                        .frame(width: 24, height: 24)
//                                        .padding()
//                                }
//                            }
//                            .frame(height: 120)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(10)
//                            .shadow(radius: 2)
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Saved Meals")
//    }
//}
//
//#Preview {
//    SavedPageView(savedMeals: .constant([Meal(idMeal: "123", strMeal: "Test Meal", strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")]), meals: .constant([]))
//}


import SwiftUI

struct SavedPageView: View {
    @Binding var savedMeals: [Meal]
    @Binding var meals: [Meal]

    // State for search and filters
    @State private var searchText: String = ""
    @State private var filteredSavedMeals: [Meal] = []
    
    @State private var selectedCategory: String = "All"
    @State private var selectedArea: String = "All"
    @State private var selectedTag: String = "All"
    
    @State private var isDataLoaded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Section with Search Bar and Filter
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.top)

                    HStack {
                        
                        // Search bar
                        TextField("Enter dish name...", text: $searchText)
                            .padding(10)
                            .frame(width: 350)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            // Live search trigger: filters meals as user types
                            .onChange(of: searchText) { _ in
                                applySearchFilter()  // Trigger search as user types
                            }
                        
                        // Filter button with NavigationLink to filter page
                        NavigationLink(destination: FilterButtonPageView(
                            meals: $meals,
                            filteredMeals: $filteredSavedMeals,
                            selectedCategory: $selectedCategory,
                            selectedArea: $selectedArea,
                            selectedTag: $selectedTag,
                            onApply: applyFilters,
                            onClear: clearFilters
                        )) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .padding(9)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                        .padding(.trailing, 10)

                    }
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0))
                }
                .ignoresSafeArea()
                .frame(height: 150)
                .cornerRadius(20)
                Spacer()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if filteredSavedMeals.isEmpty {
                            Text("No saved meals yet!")
                                .font(.title2)
                                .foregroundColor(.gray)
                        } else {
                            // Display saved meals
                            ForEach(filteredSavedMeals, id: \.idMeal) { meal in
                                NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                                    HStack {
                                        // Display meal image (first uploaded or thumbnail)
                                        if let imageData = meal.imagesData?.first, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(10)
                                        } else if let imageUrl = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
                                            AsyncImage(url: imageUrl) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 120, height: 120)
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                ProgressView()
                                                    .frame(width: 120, height: 120)
                                            }
                                        } else {
                                            // Placeholder if no image
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(10)
                                                .overlay(Text("No Image").foregroundColor(.gray))
                                        }
                                        
                                        // Meal name and save button
                                        VStack(alignment: .leading) {
                                            Text(meal.strMeal)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }

                                        // Save button to remove the meal from saved list
                                        Button(action: {
                                            if let index = savedMeals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
                                                // Remove meal from saved list
                                                savedMeals.remove(at: index)
                                                applySearchFilter()  // Update the filtered list after removal
                                            }
                                        }) {
                                            Image(systemName: "bookmark.fill")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .padding()
                                        }
                                    }
                                    .frame(height: 120)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    if !isDataLoaded {
                        applySearchFilter()
                        isDataLoaded = true
                    }
                }
            }.ignoresSafeArea()
        }
    }

    // Apply search filter
    func applySearchFilter() {
        if searchText.isEmpty {
            filteredSavedMeals = savedMeals
        } else {
            filteredSavedMeals = savedMeals.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Apply category/area/tag filters
    func applyFilters() {
        filteredSavedMeals = savedMeals
        
        if selectedCategory != "All" {
            filteredSavedMeals = filteredSavedMeals.filter { $0.strCategory == selectedCategory }
        }
        
        if selectedArea != "All" {
            filteredSavedMeals = filteredSavedMeals.filter { $0.strArea == selectedArea }
        }
        
        if selectedTag != "All" {
            filteredSavedMeals = filteredSavedMeals.filter { $0.strTags?.contains(selectedTag) == true }
        }
    }

    // Clear filters
    func clearFilters() {
        selectedCategory = "All"
        selectedArea = "All"
        selectedTag = "All"
        searchText = ""
        filteredSavedMeals = savedMeals
    }
}

#Preview {
    SavedPageView(savedMeals: .constant([Meal(idMeal: "123", strMeal: "Test Meal", strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")]), meals: .constant([]))
}
