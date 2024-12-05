//
//  DataModel.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import Foundation
import UIKit

// Response model to decode meals from API
struct MealsResponse: Codable {
    let meals: [Meal]
}

// Core model for a Meal
struct Meal: Codable, Equatable, Identifiable {
    let id: String // For Identifiable protocol compatibility
    let idMeal: String
    let strMeal: String
    let strCategory: String
    let strArea: String
    let strInstructions: String
    let strMealThumb: String
    let strYoutube: String
    let strIngredients: [String]
    let strMeasures: [String]
    let strTags: String?
    
    // Optional properties for custom images and videos
    var imageUrls: [String]? // Array to store image URLs (Firebase or other sources)
    var videoURLs: [URL]?    // Array to store video URLs
    var isUserAdded: Bool    // Indicates if the recipe is user-added
    
    // Default initializer
    init(
        id: String = UUID().uuidString,
        idMeal: String = UUID().uuidString,
        strMeal: String = "Sample Meal",
        strCategory: String = "Category",
        strArea: String = "Area",
        strInstructions: String = "Instructions",
        strMealThumb: String = "",
        strTags: String? = nil,
        strYoutube: String = "",
        strIngredients: [String] = [],
        strMeasures: [String] = [],
        imageUrls: [String]? = nil,
        videoURLs: [URL]? = nil,
        isUserAdded: Bool = false
    ) {
        self.id = id
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strCategory = strCategory
        self.strArea = strArea
        self.strInstructions = strInstructions
        self.strMealThumb = strMealThumb
        self.strYoutube = strYoutube
        self.strIngredients = strIngredients
        self.strMeasures = strMeasures
        self.imageUrls = imageUrls
        self.videoURLs = videoURLs
        self.isUserAdded = isUserAdded
        self.strTags = strTags
    }
    
    // Coding keys for dynamic encoding/decoding
    enum CodingKeys: String, CodingKey {
        case idMeal, strMeal, strCategory, strArea, strInstructions, strMealThumb, strYoutube
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
        case imageUrls, videoURLs, isUserAdded
        case strTags
    }
    
    // Custom decoding for ingredients and measures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strCategory = try container.decode(String.self, forKey: .strCategory)
        strArea = try container.decode(String.self, forKey: .strArea)
        strInstructions = try container.decode(String.self, forKey: .strInstructions)
        strMealThumb = try container.decodeIfPresent(String.self, forKey: .strMealThumb) ?? ""
        imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls)
        videoURLs = try container.decodeIfPresent([URL].self, forKey: .videoURLs)
        
        if let youtube = try container.decodeIfPresent(String.self, forKey: .strYoutube) {
            strYoutube = youtube
        } else {
            print("strYoutube missing or empty")
            strYoutube = ""
        }
        
        // Dynamically decode ingredients and measures
        var ingredients = [String]()
        var measures = [String]()
        for i in 1...20 {
            let ingredientKey = CodingKeys(stringValue: "strIngredient\(i)")!
            let measureKey = CodingKeys(stringValue: "strMeasure\(i)")!
            
            if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey), !ingredient.isEmpty {
                ingredients.append(ingredient)
            }
            if let measure = try container.decodeIfPresent(String.self, forKey: measureKey), !measure.isEmpty {
                measures.append(measure)
            }
        }
        strIngredients = ingredients
        strMeasures = measures
        
        // Initialize additional properties with defaults
        id = UUID().uuidString // Ensure `id` is always set
        isUserAdded = try container.decodeIfPresent(Bool.self, forKey: .isUserAdded) ?? false
        strTags = try container.decodeIfPresent(String.self, forKey: .strTags)
        
    }
    
    // Custom encoding for dynamic ingredients and measures
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idMeal, forKey: .idMeal)
        try container.encode(strMeal, forKey: .strMeal)
        try container.encode(strCategory, forKey: .strCategory)
        try container.encode(strArea, forKey: .strArea)
        try container.encode(strInstructions, forKey: .strInstructions)
        try container.encode(strMealThumb, forKey: .strMealThumb)
        try container.encodeIfPresent(strYoutube, forKey: .strYoutube)
        try container.encodeIfPresent(imageUrls, forKey: .imageUrls)
        try container.encodeIfPresent(videoURLs, forKey: .videoURLs)
        try container.encode(isUserAdded, forKey: .isUserAdded)
        try container.encode(strTags, forKey: .strTags)
        
        // Encode ingredients and measures dynamically
        for (index, ingredient) in strIngredients.enumerated() {
            let ingredientKey = CodingKeys(stringValue: "strIngredient\(index + 1)")!
            try container.encode(ingredient, forKey: ingredientKey)
        }
        for (index, measure) in strMeasures.enumerated() {
            let measureKey = CodingKeys(stringValue: "strMeasure\(index + 1)")!
            try container.encode(measure, forKey: measureKey)
        }
    }
}

// Protocol for notifying when a recipe is added
protocol RecipeDelegate: AnyObject {
    func didAddRecipe(recipe: Meal)
}
