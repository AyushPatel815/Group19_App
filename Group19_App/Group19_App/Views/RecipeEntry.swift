//
//  RecipeEntry.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//


import SwiftUI

struct RecipeEntry: View {
    @Binding var meals: [Meal]  // Binding to meals from parent view
    var searchText: String       // Search text for filtering
    @Binding var savedMeals: [Meal]  // Binding for saved meals

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
                ForEach(filteredMeals, id: \.idMeal) { meal in
                    // Wrap meal entry inside a NavigationLink to navigate to RecipeDetailPageView
                    NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                        HStack {
                            if let imageData = meal.imagesData?.first, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 200)
                                    .cornerRadius(10)
                            } else if let imageUrl = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
                                // If no uploaded image, use the meal thumbnail from API
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
                                // Add to saved meals if not already saved
                                if let index = savedMeals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
                                    savedMeals.remove(at: index)  // Remove from saved meals if already saved
                                } else {
                                    savedMeals.append(meal)  // Add to saved meals if not saved
                                }
                            }) {
                                Image(systemName: savedMeals.contains(where: { $0.idMeal == meal.idMeal }) ? "bookmark.fill" : "bookmark")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 18, height: 30)
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
}

#Preview {
    RecipeEntry(meals: .constant([Meal(idMeal: "123", strMeal: "Test Meal", strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg", imagesData: nil)]), searchText: "", savedMeals: .constant([]))
}
