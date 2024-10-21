//
//  MealService.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import Foundation



struct MealService {
    // Function to fetch meals data
    func fetchMeals() async throws -> [Meal] {
        // Define the URL for the API call
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?f=b") else {
            throw URLError(.badURL)
        }
        
        // Make the network request
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decode the JSON data into Swift models
        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        
        // Return the meals array
        return mealsResponse.meals
    }
}
