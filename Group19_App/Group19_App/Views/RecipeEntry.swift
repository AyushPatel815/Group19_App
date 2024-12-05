//
//  RecipeEntry.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RecipeEntry: View {
    @Binding var meals: [Meal]  // Binding to meals from parent view
    var searchText: String       // Search text for filtering
    @Binding var savedMeals: [Meal]  // Binding for saved meals
    var onSave: (Meal) -> Void  // Closure to handle saving a recipe
    
    
    // Filter meals based on search text
    var filteredMeals: [Meal] {
        if searchText.isEmpty {
            return meals
        } else {
            return meals.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(filteredMeals) { meal in
                    
                    // Wrap meal entry inside a NavigationLink to navigate to RecipeDetailPageView
                    NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                        HStack {
                            // Display meal image with improved AsyncImage handling
                            if let imageUrl = meal.imageUrls?.first, let url = URL(string: imageUrl) {
                                CustomAsyncImage(url: url)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                
                            } else if let imageUrl = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
                                CustomAsyncImage(url: imageUrl)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                
                            } else {
                                // Placeholder if no image is available
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .overlay(Text("No Image").foregroundColor(.gray))
                                
                            }
                            
                            // Dish Name on the right
                            Text(meal.strMeal)
                                .font(.headline)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Save Icon on the far right
                            Button(action: {
                                saveRecipe(meal)  // Call the onSave closure when the button is tapped
                            }) {
                                Image(systemName: savedMeals.contains(where: { $0.idMeal == meal.idMeal }) ? "heart.fill" : "heart")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 28, height: 30)
                                    .padding()
                            }
                        }
                        .frame(height: 120) // Fixed height for each entry
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
            }
            .padding()
        }
    }
    // SaveRecipe function to save recipe and update entry in firebase
    func saveRecipe(_ meal: Meal) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let recipeRef = db.collection("users").document(userID).collection("savedRecipes").document(meal.idMeal)
        
        if savedMeals.contains(where: { $0.idMeal == meal.idMeal }) {
            // Unsaving the meal
            recipeRef.delete { error in
                if let error = error {
                    print("Failed to unsave recipe: \(error)")
                } else {
                    savedMeals.removeAll { $0.idMeal == meal.idMeal }
                }
            }
        } else {
            // Saving the meal
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
}

/// Custom AsyncImage with enhanced error handling
struct CustomAsyncImage: View {
    let url: URL
    
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        if let uiImage = uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .cornerRadius(10)
                .padding(.trailing)
        } else if isLoading {
            ProgressView()
                .frame(width: 120, height: 120)
                .onAppear {
                    loadImage()
                }
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
                .cornerRadius(10)
                .overlay(Text("No Image").foregroundColor(.gray))
        }
    }
    
    // Asynchronously load image without hurting other UI component or rendering
    private func loadImage() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("Failed to load image from URL: \(url) - Error: \(String(describing: error))")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }.resume()
    }
    
}



#Preview {
    RecipeEntry(
        meals: .constant([Meal(
            idMeal: "123",
            strMeal: "Test Meal",
            strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
            imageUrls: ["https://firebasestorage.googleapis.com:443/v0/b/group19app-3bd2e.firebasestorage.app/o/users%2FecjGyChqk1P14Jmm0LnPmdB2rAu1%2Frecipes%2F87E58EF8-8A86-4130-8A95-2122CCDB6FA7%2F06AC4076-EE54-4A6F-9CE7-1A84CF960C12.jpg?alt=media&token=d164c75d-9d20-4423-bc2f-78f01d38081b"]
        )]),
        searchText: "",
        savedMeals: .constant([]),
        onSave: { _ in }
    )
}
