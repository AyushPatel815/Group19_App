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
        VStack(spacing: 0) {
            // Top yellow bar
            ZStack {
                Color.yellow
                    .edgesIgnoringSafeArea(.top) // Ignore only the top safe area
                
                HStack {
                    Text(meal.strMeal)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding(.top, 50) // Adjust padding from the top for content
                .frame(maxWidth: .infinity)
            }
            .frame(height: 150)
            .cornerRadius(20)
            .ignoresSafeArea()// Fix the height of the yellow bar
            .padding(.bottom,-50)//doesnt fix the issue from appearing in contentView
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
                        .font(.title2.bold())
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
                        .font(.title2.bold())
                        .padding(.top, 10)

                    Text(meal.strInstructions)
                        .font(.body)
                        .padding(.top, 5)

                    // Tags
                    if let tags = meal.strTags {
                        Text("Tags: \(tags)")
                            .font(.subheadline.bold())
                            .padding(.top, 5)
                    }
                }
                .padding() // Padding for content within the scroll view
            }
            .padding(.bottom, 65) // For the safe area at the bottom (e.g., when having a tab bar)
        }
    }

    // Function to convert the YouTube URL to an embeddable version
    func getYouTubeEmbedURL(youtubeLink: String) -> String {
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
