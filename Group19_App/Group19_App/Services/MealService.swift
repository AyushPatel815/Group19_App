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

//
//
//struct MealService {
//    // Function to fetch meals data for a specific letter
//    func fetchMeals(for letter: Character) async throws -> [Meal] {
//        // Define the URL for the API call
//        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?f=\(letter)") else {
//            throw URLError(.badURL)
//        }
//        
//        // Make the network request
//        let (data, _) = try await URLSession.shared.data(from: url)
//        
//        // Decode the JSON data into Swift models, handle optional meals
//        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
//        return mealsResponse.meals  // Return empty array if no meals are found
//    }
//    
//    // Function to fetch meals for all letters from a to z
//    func fetchAllMeals() async throws -> [Meal] {
//        var allMeals: [Meal] = []
//        
//        // Iterate through letters a to z
//        for letter in "abcdefghijklmnopqrstuvwxyz" {
//            do {
//                let mealsForLetter = try await fetchMeals(for: letter)
//                allMeals.append(contentsOf: mealsForLetter)
//            } catch {
//                print("Error fetching meals for letter \(letter): \(error)")
//                // Handle the error (e.g., continue to next letter if there's an error)
//            }
//        }
//        
//        return allMeals
//    }
//}


import Foundation

// Helper function to get the URL for the Documents directory
func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

struct MealService {
    // MARK: - Meal Fetching from API
    
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
        return mealsResponse.meals
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
    
    // Function to fetch meal by ID
    func fetchMeal(by id: String) async throws -> Meal? {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        return mealsResponse.meals.first
    }
    
    // Function to fetch meals by category
    func fetchMealsByCategory(_ category: String) async throws -> [Meal] {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        return mealsResponse.meals
    }

    // Function to fetch meals by area
    func fetchMealsByArea(_ area: String) async throws -> [Meal] {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?a=\(area)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        return mealsResponse.meals
    }

    // Function to search meals by name
    func searchMeals(by name: String) async throws -> [Meal] {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(name)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
        return mealsResponse.meals
    }
    
    // Function to fetch all meal categories
    func fetchAllCategories() async throws -> [Category] {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let categoryResponse = try JSONDecoder().decode(CategoriesResponse.self, from: data)
        return categoryResponse.categories
    }

    // MARK: - Local Storage (Saving and Loading Meals)
    
    // Function to save meals to a JSON file
    func saveMeals(_ meals: [Meal]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(meals) {
            let url = getDocumentsDirectory().appendingPathComponent("savedMeals.json")
            try? encodedData.write(to: url)
        }
    }

    // Function to load meals from a JSON file
    func loadMeals() -> [Meal] {
        let url = getDocumentsDirectory().appendingPathComponent("savedMeals.json")
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedMeals = try? decoder.decode([Meal].self, from: data) {
                return decodedMeals
            }
        }
        return []
    }
}

// Category model and response struct
struct CategoriesResponse: Codable {
    let categories: [Category]
}

struct Category: Codable {
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
}
