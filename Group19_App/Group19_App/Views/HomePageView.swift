//
//  HomePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import SwiftUI

struct HomePageView: View {
    @State private var searchText: String = ""
    @State private var meals: [Meal] = []
    @Binding var savedMeals: [Meal]

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Color.yellow
                        .edgesIgnoringSafeArea(.top)

                    HStack {
                        // Search bar
                        TextField("Enter dish name...", text: $searchText)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.leading, 10)

                        Button(action: {
                            // Action for filter button
                        }) {
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

                // Updated RecipeEntry with Navigation
                RecipeEntry(meals: $meals, searchText: searchText, savedMeals: $savedMeals)
            }
            .ignoresSafeArea()
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
    }

    // Function to load data using MealService
    func loadData() async {
        do {
            let fetchedMeals = try await MealService().fetchMeals()
            meals = fetchedMeals // Assign fetched meals to the state variable
        } catch {
            print("Error fetching meals: \(error)")
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(savedMeals: .constant([]))
    }
}
