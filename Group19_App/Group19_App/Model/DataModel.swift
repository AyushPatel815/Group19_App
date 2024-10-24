//
//  DataModel.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import Foundation
import UIKit

// MealsResponse to decode response from API
struct MealsResponse: Codable {
    let meals: [Meal]
}

// Meal struct with dynamic ingredients and measures
struct Meal: Codable {
    let idMeal: String
    let strMeal: String
    let strDrinkAlternate: String?
    let strCategory: String
    let strArea: String
    let strInstructions: String
    let strMealThumb: String
    let strTags: String?
    let strYoutube: String
    let strIngredients: [String]
    let strMeasures: [String]
    
    var imagesData: [Data]? // Array to hold multiple image data
    var videoURLs: [URL]?   // Array to hold video URLs

    var images: [UIImage]? {
        if let data = imagesData {
            return data.compactMap { UIImage(data: $0) }
        }
        return nil
    }

    init(
        idMeal: String = UUID().uuidString,
        strMeal: String = "Sample Meal",
        strDrinkAlternate: String? = nil,
        strCategory: String = "Category",
        strArea: String = "Area",
        strInstructions: String = "Instructions",
        strMealThumb: String = "",
        strTags: String? = nil,
        strYoutube: String = "",
        strIngredients: [String] = [],
        strMeasures: [String] = [],
        imagesData: [Data]? = nil,
        videoURLs: [URL]? = nil
    ) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strDrinkAlternate = strDrinkAlternate
        self.strCategory = strCategory
        self.strArea = strArea
        self.strInstructions = strInstructions
        self.strMealThumb = strMealThumb
        self.strTags = strTags
        self.strYoutube = strYoutube
        self.strIngredients = strIngredients
        self.strMeasures = strMeasures
        self.imagesData = imagesData
        self.videoURLs = videoURLs
    }


    // CodingKeys to dynamically decode ingredients and measures
    enum CodingKeys: String, CodingKey {
        case idMeal, strMeal, strDrinkAlternate, strCategory, strArea, strInstructions, strMealThumb, strTags, strYoutube
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6
        case strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12
        case strIngredient13, strIngredient14, strIngredient15, strIngredient16, strIngredient17, strIngredient18
        case strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6
        case strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12
        case strMeasure13, strMeasure14, strMeasure15, strMeasure16, strMeasure17, strMeasure18
        case strMeasure19, strMeasure20
    }

    // Custom decoder to handle dynamic ingredients and measures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strDrinkAlternate = try container.decodeIfPresent(String.self, forKey: .strDrinkAlternate)
        strCategory = try container.decode(String.self, forKey: .strCategory)
        strArea = try container.decode(String.self, forKey: .strArea)
        strInstructions = try container.decode(String.self, forKey: .strInstructions)
        strMealThumb = try container.decode(String.self, forKey: .strMealThumb)
        strTags = try container.decodeIfPresent(String.self, forKey: .strTags)
        strYoutube = try container.decode(String.self, forKey: .strYoutube)
        
        // Dynamic decoding for ingredients and measures
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
        self.strIngredients = ingredients
        self.strMeasures = measures
    }

    // Custom encoder for dynamic ingredients and measures
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idMeal, forKey: .idMeal)
        try container.encode(strMeal, forKey: .strMeal)
        try container.encodeIfPresent(strDrinkAlternate, forKey: .strDrinkAlternate)
        try container.encode(strCategory, forKey: .strCategory)
        try container.encode(strArea, forKey: .strArea)
        try container.encode(strInstructions, forKey: .strInstructions)
        try container.encode(strMealThumb, forKey: .strMealThumb)
        try container.encodeIfPresent(strTags, forKey: .strTags)
        try container.encode(strYoutube, forKey: .strYoutube)
        
        // Dynamic encoding for ingredients and measures
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

// Define a delegate protocol to handle saving the recipe
protocol RecipeDelegate {
    func didAddRecipe(recipe: Meal)  // Notify the delegate when a recipe is added
}
