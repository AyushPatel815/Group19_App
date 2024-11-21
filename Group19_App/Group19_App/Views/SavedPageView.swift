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
import FirebaseFirestore
import FirebaseAuth

struct SavedPageView: View {
    @Binding var savedMeals: [Meal]
    @Binding var meals: [Meal]

    // State for search and filters specific to SavedPageView
    @State private var searchText: String = ""
    @State private var filteredSavedMeals: [Meal] = []
    
    // Separate filter states for SavedPageView
    @State private var selectedCategorySaved: String = "All"
    @State private var selectedAreaSaved: String = "All"
    @State private var selectedTagSaved: String = "All"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Section: Search Bar and Filter
                topBarSection()

                Spacer()
                
                // Scrollable List of Saved Meals
                ScrollView {
                    VStack(spacing: 20) {
                        if filteredSavedMeals.isEmpty {
                            Text("No saved meals yet!")
                                .font(.title2)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(filteredSavedMeals, id: \.idMeal) { meal in
                                NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                                    savedMealRow(for: meal)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    fetchSavedRecipes()
                }
                .onChange(of: savedMeals) { _ in
                    applyFilters()
                }

            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Top Bar Section
    @ViewBuilder
    private func topBarSection() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.top)

            HStack {
                // Search bar for saved meals
                TextField("Enter dish name...", text: $searchText)
                    .padding(10)
                    .frame(width: 350)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .onChange(of: searchText) { _ in
                        applyFilters()
                    }

                // Filter button for Saved Meals
                NavigationLink(destination: filterPageView()) {
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
        .frame(height: 150)
        .cornerRadius(20)
    }

    // MARK: - Filter Page View
    @ViewBuilder
    private func filterPageView() -> some View {
        FilterButtonPageView(
            meals: $meals,
            filteredMeals: $filteredSavedMeals,
            selectedCategory: $selectedCategorySaved,
            selectedArea: $selectedAreaSaved,
            selectedTag: $selectedTagSaved,
            onApply: applyFilters,
            onClear: clearFilters
        )
    }

    // MARK: - Saved Meal Row
    @ViewBuilder
    private func savedMealRow(for meal: Meal) -> some View {
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
                removeRecipe(meal)
            }) {
                Image(systemName: "bookmark.fill")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 18, height: 30)
                    .padding()
            }
        }
        .frame(height: 120)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    // MARK: - Filter and Search Logic
    func applyFilters() {
        var filtered = savedMeals

        // Apply category filter
        if selectedCategorySaved != "All" {
            filtered = filtered.filter { $0.strCategory == selectedCategorySaved }
        }
        
        // Apply area filter
        if selectedAreaSaved != "All" {
            filtered = filtered.filter { $0.strArea == selectedAreaSaved }
        }
        
        // Apply tag filter
        if selectedTagSaved != "All" {
            filtered = filtered.filter { $0.strTags?.contains(selectedTagSaved) == true }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
        }
        
        filteredSavedMeals = filtered
    }

    func clearFilters() {
        selectedCategorySaved = "All"
        selectedAreaSaved = "All"
        selectedTagSaved = "All"
        searchText = ""
        filteredSavedMeals = savedMeals
    }

    // MARK: - Remove Recipe
    func removeRecipe(_ meal: Meal) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let recipeRef = db.collection("users").document(userID).collection("savedRecipes").document(meal.idMeal)

        recipeRef.delete { error in
            if let error = error {
                print("Failed to remove recipe: \(error)")
            } else {
                savedMeals.removeAll { $0.idMeal == meal.idMeal }
            }
        }
    }

    // MARK: - Fetch Saved Recipes
    func fetchSavedRecipes() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let recipesRef = db.collection("users").document(userID).collection("savedRecipes")

        recipesRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching saved recipes: \(error)")
                return
            }

            savedMeals = snapshot?.documents.compactMap { document in
                try? document.data(as: Meal.self)
            } ?? []
            applyFilters()
        }
    }
}


#Preview {
    SavedPageView(
        savedMeals: .constant([
            Meal(
                idMeal: "123",
                strMeal: "Test Meal",
                strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg"
            )
        ]),
        meals: .constant([])
    )
}
