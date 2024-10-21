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
    @Binding var savedMeals: [Meal]  // Binding for saved meals
    @Binding var meals: [Meal]  // Binding to meals from parent view (can be removed if unnecessary)

    var body: some View {
        NavigationStack {  // Ensure it's wrapped in a NavigationStack
            ScrollView {
                VStack(spacing: 20) {
                    if savedMeals.isEmpty {
                        Spacer()
                        Text("No saved meals yet!")
                            .font(.title2)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(savedMeals, id: \.idMeal) { meal in
                            NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
                                HStack {
                                    // Image on the left
                                    if let imageUrl = URL(string: meal.strMealThumb) {
                                        AsyncImage(url: imageUrl) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                    }

                                    // Meal name on the right
                                    Text(meal.strMeal)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    // Save/Remove Icon on the far right
                                    Button(action: {
                                        // Remove from saved meals if already saved
                                        if let index = savedMeals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
                                            savedMeals.remove(at: index)
                                        }
                                    }) {
                                        Image("saveFill")  // Since it's already saved, always show 'saveFill'
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
            .navigationTitle("Saved Meals")
        }
    }
}

#Preview {
    SavedPageView(savedMeals: .constant([Meal(idMeal: "123", strMeal: "Test Meal", strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")]), meals: .constant([]))
}
