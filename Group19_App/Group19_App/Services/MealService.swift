//
//  MealService.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import Foundation



//struct MealService {
//    // Function to fetch meals data
//    func fetchMeals() async throws -> [Meal] {
//        // Define the URL for the API call
//        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?f=b") else {
//            throw URLError(.badURL)
//        }
//        
//        // Make the network request
//        let (data, _) = try await URLSession.shared.data(from: url)
//        
//        // Decode the JSON data into Swift models
//        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
//        
//        // Return the meals array
//        return mealsResponse.meals
//    }
//}



struct MealService {
    // Function to fetch meals data for a specific letter
    func fetchMeals(for letter: Character) async throws -> [Meal] {
        // Define the URL for the API call
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?f=\(letter)") else {
            throw URLError(.badURL)
        }
        
        // Make the network request
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decode the JSON data into Swift models, handle optional meals
        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        return mealsResponse.meals  // Return empty array if no meals are found
    }
    
    // Function to fetch meals for all letters from a to z
    func fetchAllMeals() async throws -> [Meal] {
        var allMeals: [Meal] = []
        
        // Iterate through letters a to z
        for letter in "abcdefghijklmnopqrstuvwxyz" {
            do {
                let mealsForLetter = try await fetchMeals(for: letter)
                allMeals.append(contentsOf: mealsForLetter)
            } catch {
                print("Error fetching meals for letter \(letter): \(error)")
                // Handle the error (e.g., continue to next letter if there's an error)
            }
        }
        
        return allMeals
    }
}
