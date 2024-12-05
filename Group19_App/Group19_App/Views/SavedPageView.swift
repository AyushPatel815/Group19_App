//
//  SavedPageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SavedPageView: View {
    @Binding var savedMeals: [Meal]   // List of saved meals (from parent view)
    @Binding var meals: [Meal]  // All meals data (if needed globally)

    @State private var searchText: String = ""    // Search bar text
    @State private var filteredSavedMeals: [Meal] = []    // Meals filtered based on search and filters

    @State private var selectedCategorySaved: String = "All"    // Selected category filter
    @State private var selectedAreaSaved: String = "All"   // Selected area filter
    @State private var selectedTagSaved: String = "All"    // Selected tag filter
    @State private var searchBarState: Bool = false    // Toggle for search bar visibility
    @State private var isLoading: Bool = false
    @State private var loadedImages: [String: UIImage] = [:] // Dictionary to cache loaded images by URL


    
    private let db = Firestore.firestore()
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar with Search and Filter
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.top)

                    HStack(spacing: -35) {
                        Spacer().frame(width: 90)
                        AnimatedSearchBar(searchtext: $searchText)
                            .onChange(of: searchText) { _ in applyFilters() }
                            .frame(maxWidth: .infinity)

                        // Filter Button
                        if !searchBarState {
                            Spacer().frame(width: 70)
                            NavigationLink(destination: FilterButtonPageView(
                                meals: $savedMeals,
                                filteredMeals: $filteredSavedMeals,
                                selectedCategory: $selectedCategorySaved,
                                selectedArea: $selectedAreaSaved,
                                selectedTag: $selectedTagSaved,
                                onApply: applyFilters,
                                onClear: clearFilters
                            )) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.title)
                                    .foregroundStyle(.black)
                                    .padding(5)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0))
                }
                .frame(height: 120)
                .cornerRadius(20)

                // Saved Meals List
                ScrollView {
                    VStack(spacing: 20) {
                        if filteredSavedMeals.isEmpty {
                            Text("No saved meals yet!")
                                .font(.title2)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(filteredSavedMeals, id: \.idMeal) { meal in
                                NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                                    HStack {
                                        if let urlString = meal.imageUrls?.first ?? (meal.strMealThumb.isEmpty ? nil : meal.strMealThumb),
                                           let url = URL(string: urlString) {
                                            ZStack {
                                                if let image = loadedImages[urlString] {
                                                    // Display the cached image
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 120, height: 120)
                                                        .cornerRadius(10)
                                                } else {
                                                    // Show a ProgressView while the image is loading
                                                    ProgressView()
                                                        .frame(width: 120, height: 120)
                                                        .onAppear {
                                                            loadImage(from: url, for: urlString)
                                                        }
                                                }
                                            }
                                        }
                                        else {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(10)
                                                .overlay(Text("No Image").foregroundColor(.gray))
                                        }

                                        VStack(alignment: .leading) {
                                            Text(meal.strMeal)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }

                                        Button(action: {
                                            removeRecipe(meal)
                                        }) {
                                            Image(systemName: "heart.fill")
                                                .resizable()
                                                .foregroundColor(.black)
                                                .frame(width: 28, height: 30)
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
                    Spacer()
                        .frame(height: 100)
                }
                .onAppear {
                        fetchAndUpdateSavedMeals() // Always fetch data when this view appears
                    
                }
                .onChange(of: savedMeals) { _ in
                    applyFilters()    // Reapply filters when savedMeals changes
                }
                
                
            }
            .ignoresSafeArea()
        }
    }

    // Apply filters based on user selections
    func applyFilters() {
        var filtered = savedMeals

        if selectedCategorySaved != "All" {
            filtered = filtered.filter { $0.strCategory == selectedCategorySaved }
        }

        if selectedAreaSaved != "All" {
            filtered = filtered.filter { $0.strArea == selectedAreaSaved }
        }

        if selectedTagSaved != "All" {
            filtered = filtered.filter { $0.strTags?.contains(selectedTagSaved) == true }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
        }

        DispatchQueue.main.async {
            filteredSavedMeals = filtered
        }
    }

    // Clear all applied filters
    func clearFilters() {
        selectedCategorySaved = "All"
        selectedAreaSaved = "All"
        selectedTagSaved = "All"
        searchText = ""
        filteredSavedMeals = savedMeals
    }

    // Remove a recipe from saved meals
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
    
    // Fetch saved meals from Firestore and update the UI
    private func fetchAndUpdateSavedMeals() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            return
        }

        isLoading = true
        FirestoreHelper.shared.fetchSavedMeals(for: userID) { fetchedMeals in
            DispatchQueue.main.async {
                self.savedMeals = fetchedMeals
                self.filteredSavedMeals = fetchedMeals
                self.applyFilters()
                self.isLoading = false
            }
        }
    }
    
    // Load images asynchronously and cache them
    private func loadImage(from url: URL, for urlString: String) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        loadedImages[urlString] = uiImage // Cache the loaded image
                    }
                }
            } catch {
                print("Error loading image from \(url.absoluteString): \(error)")
            }
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
