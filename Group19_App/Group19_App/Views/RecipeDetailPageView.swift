//
//  RecipeDetailPageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct RecipeDetailPageView: View {
    var meal: Meal  // Pass the meal object to show its details

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image and YouTube link slider
                TabView {
                    // Meal Image
                    if let url = URL(string: meal.strMealThumb) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: .infinity, height: 300)
                                .cornerRadius(10)
                                .padding()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // YouTube Video in a WebView
                    if let youtubeURL = URL(string: getYouTubeEmbedURL(youtubeLink: meal.strYoutube)) {
                        WebView(url: youtubeURL)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle()) // Make it look like a slider

                // Meal Name
                Text(meal.strMeal)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                // Category and Area (Cuisine)
                HStack {
                    Text("Category: \(meal.strCategory)")
                        .font(.subheadline)
                    Spacer()
                    Text("Area: \(meal.strArea)")
                        .font(.subheadline)
                }
                .padding(.bottom, 5)
                
                // Ingredients and Measures
                Text("Ingredients")
                    .font(.title2)
                    .padding(.top, 5)
                
                ForEach(0..<meal.strIngredients.count, id: \.self) { index in
                    HStack {
                        Text("\(meal.strMeasures[index])")
                            .font(.subheadline)
                        Text(meal.strIngredients[index])
                            .font(.subheadline)
                    }
                }
                
                // Instructions
                Text("Instructions")
                    .font(.title2)
                    .padding(.top, 10)
                
                Text(meal.strInstructions)
                    .font(.body)
                    .padding(.top, 5)
                
                // Tags
                if let tags = meal.strTags {
                    Text("Tags: \(tags)")
                        .font(.subheadline)
                        .padding(.top, 5)
                }
            }
            .padding()
            
        }
        .padding(.bottom,65)
        .navigationTitle(meal.strMeal)
        .navigationBarTitleDisplayMode(.inline)
    }

    // Function to convert the YouTube URL to an embeddable version
    func getYouTubeEmbedURL(youtubeLink: String) -> String {
        // Convert standard YouTube link to an embed link
        if let videoID = youtubeLink.components(separatedBy: "v=").last {
            return "https://www.youtube.com/embed/\(videoID)"
        }
        return youtubeLink
    }
}

#Preview {
    RecipeDetailPageView(meal: Meal(
        idMeal: "52772",
        strMeal: "Spaghetti Carbonara",
        strDrinkAlternate: nil,
        strCategory: "Pasta",
        strArea: "Italian",
        strInstructions: "Boil the spaghetti. Fry the pancetta. Beat the eggs and mix with cheese. Combine spaghetti, pancetta, and egg mixture. Serve immediately.",
        strMealThumb: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg",
        strTags: "Pasta,Comfort Food",
        strYoutube: "https://www.youtube.com/watch?v=3AAdKl1UYZs",
        strIngredients: ["Spaghetti", "Pancetta", "Eggs", "Parmesan Cheese", "Black Pepper"],
        strMeasures: ["200g", "100g", "2", "50g", "to taste"]
    ))
}
