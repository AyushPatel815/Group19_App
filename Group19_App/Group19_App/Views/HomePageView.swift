//
//  HomePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomePageView: View {
    @Binding var meals: [Meal]  // Meals is now a binding from the parent view
    @Binding var savedMeals: [Meal]
    
    @State private var searchText: String = ""
    @State private var filteredMeals: [Meal] = []
    
    // State variables for selected filter options
    @State private var selectedCategory: String = "All"
    @State private var selectedArea: String = "All"
    @State private var selectedTag: String = "All"
    
    @State private var isDataLoaded = false
    @State private var randomMeals: [Meal] = []

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.top)

                    HStack {
                        Image(.appLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        // Search bar
                        TextField("Enter dish name...", text: $searchText, onCommit: {
                            applySearchFilter()
                        })
                        .padding(10)
                        .frame(width: 250)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)

                        // Filter button with NavigationLink to filter page
                        NavigationLink(destination: FilterButtonPageView(
                            meals: $meals,
                            filteredMeals: $filteredMeals,
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
                .frame(height: 150)
                .cornerRadius(20)
                
                ScrollView {
                    VStack {
                        // Hide the carousel if search is active or filters are applied
                        if searchText.isEmpty && selectedCategory == "All" && selectedArea == "All" && selectedTag == "All" {
                            if !randomMeals.isEmpty {
                                TabView {
                                    ForEach(randomMeals, id: \.idMeal) { meal in
                                        NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                                            if let url = URL(string: meal.strMealThumb) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(height: 200)
                                                        .cornerRadius(10)
                                                        .padding(.horizontal)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: .infinity, height: 200)
                                .ignoresSafeArea()
                                .tabViewStyle(PageTabViewStyle()) // Enable carousel effect
                            }
                        }

                        // Updated RecipeEntry with Navigation, showing filtered meals
                        RecipeEntry(meals: $filteredMeals, searchText: searchText, savedMeals: $savedMeals, onSave: saveRecipe)

                        // Add Clear Filter button after the filtered meals
                        if selectedCategory != "All" || selectedArea != "All" || selectedTag != "All" || !searchText.isEmpty {
                            Button(action: {
                                clearFilters() // Call clear filter function
                            }) {
                                Text("Clear Filters")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding(.top, 10)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    Spacer()
                        .frame(height: 100)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                if !isDataLoaded {
                    Task {
                        await loadData()
                        await fetchSavedRecipes()
                        await mergeAndSortRecipes()
//                        FirestoreHelper.shared.listenForAllRecipes(existingRecipes: meals) { newRecipes in
//                                        DispatchQueue.main.async {
//                                            meals.append(contentsOf: newRecipes)
//                                            filteredMeals = meals // Update the filtered list for display
//                                        }
//                                    }
                        isDataLoaded = true
                    }
                    
                    // Real-time updates for all user recipes
//                            FirestoreHelper.shared.listenForAllRecipes { recipes in
//                                DispatchQueue.main.async {
//                                    meals = (meals.filter { !$0.isUserAdded } + recipes).sorted { $0.strMeal < $1.strMeal }
//                                    filteredMeals = meals
//                                }
//                            }
                } else {
                    applyFilters()
//                    applySearchFilter()
                    
                }
            }
        }
    }
    
    
    // Function to fetch and merge recipes
    func mergeAndSortRecipes() async {
        do {
            let apiMeals = try await MealService().fetchAllMeals()
            var allUserMeals: [Meal] = []

            // Fetch all user recipes from Firestore
            FirestoreHelper.shared.fetchAllUserRecipes { userMeals in
                allUserMeals = userMeals

                // Deduplicate recipes by `idMeal`
                var uniqueMeals = [String: Meal]()
                (apiMeals + allUserMeals).forEach { meal in
                    uniqueMeals[meal.idMeal] = meal
                }

                // Convert back to an array and sort
                meals = Array(uniqueMeals.values).sorted { $0.strMeal < $1.strMeal }

                // Update filteredMeals for the UI
                filteredMeals = meals

                // Select random meals for the carousel
                randomMeals = Array(meals.shuffled().prefix(5))
            }
        } catch {
            print("Error merging recipes: \(error)")
        }
    }


    
    // Function to load data using MealService
    func loadData() async {
        do {
            let fetchedMeals = try await MealService().fetchAllMeals()
            meals = fetchedMeals  // Assign fetched meals to the state variable
            filteredMeals = meals  // Initially show all meals
            
            // Select 5 random meals for the carousel
            randomMeals = Array(meals.shuffled().prefix(5))
            
        } catch {
            print("Error fetching meals: \(error)")
        }
    }


    // Function to filter meals based on search text
    func applySearchFilter() {
        if searchText.isEmpty {
            filteredMeals = meals  // If search text is empty, show all meals
        } else {
            filteredMeals = meals.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // Function to apply filters and update filteredMeals
    func applyFilters() {
        // Apply filtering logic based on the selected category, area, and tags
        filteredMeals = meals
        
        if selectedCategory != "All" {
            filteredMeals = filteredMeals.filter { $0.strCategory == selectedCategory }
        }
        
        if selectedArea != "All" {
            filteredMeals = filteredMeals.filter { $0.strArea == selectedArea }
        }
        
        if selectedTag != "All" {
            filteredMeals = filteredMeals.filter { $0.strTags?.contains(selectedTag) == true }
        }
    }

    // Function to clear all filters and reload all meals
    func clearFilters() {
        selectedCategory = "All"
        selectedArea = "All"
        selectedTag = "All"
        searchText = ""
        filteredMeals = meals // Reset the filtered meals to show all
    }
    
    
    func fetchSavedRecipes() async {
            guard let userID = Auth.auth().currentUser?.uid else { return }

            let db = Firestore.firestore()
            let recipesRef = db.collection("users").document(userID).collection("savedRecipes")

            do {
                let snapshot = try await recipesRef.getDocuments()
                let fetchedMeals = snapshot.documents.compactMap { document -> Meal? in
                    try? document.data(as: Meal.self)
                }
                savedMeals = fetchedMeals
            } catch {
                print("Error fetching saved recipes: \(error)")
            }
        }
    
    func saveRecipe(_ meal: Meal) {
            guard let userID = Auth.auth().currentUser?.uid else { return }

            let db = Firestore.firestore()
            let recipeRef = db.collection("users").document(userID).collection("savedRecipes").document(meal.idMeal)

            do {
                try recipeRef.setData(from: meal) { error in
                    if let error = error {
                        print("Failed to save recipe: \(error)")
                    } else {
                        savedMeals.append(meal)
                    }
                }
            } catch {
                print("Error encoding meal: \(error)")
            }
        }
    
}

#Preview {
    HomePageView(meals: .constant([]), savedMeals: .constant([]))
}
