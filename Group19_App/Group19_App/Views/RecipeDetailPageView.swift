//
//  RecipeDetailPageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import SwiftUI
import WebKit

// WebView to display YouTube videos
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct RecipeDetailPageView: View {
    var meal: Meal
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing:0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image and YouTube link slider
                    TabView {
                        // Display all images if available
                        if let imageUrls = meal.imageUrls, !imageUrls.isEmpty {
                            ForEach(imageUrls, id: \.self) { imageUrl in
                                if let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, maxHeight: 300)
                                            .cornerRadius(10)
                                            .padding()
                                    } placeholder: {
                                        ProgressView()
                                            .frame(maxWidth: .infinity, maxHeight: 300)
                                    }
                                }
                            }
                        } else if let url = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
                            // Load from URL if no local images
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                                    .cornerRadius(10)
                                    .padding()
                            } placeholder: {
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                            }
                        } else {
                            // Placeholder for no image
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(10)
                                .overlay(Text("No Image").foregroundColor(.gray))
                                .padding()
                        }

                        // Conditionally show YouTube video if the link is provided
                        if !meal.strYoutube.isEmpty, let youtubeURL = URL(string: getYouTubeEmbedURL(youtubeLink: meal.strYoutube)) {
                            WebView(url: youtubeURL)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(10)
                                .padding()
                        }
//                        if !meal.strYoutube.isEmpty, let youtubeURL = URL(string: meal.strYoutube) {
//                            WebView(url: youtubeURL)
//                                .frame(maxWidth: .infinity, maxHeight: 300)
//                                .cornerRadius(10)
//                                .padding()
//                        } else {
//                            Text("No YouTube video available.")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }


                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle()) // Make it look like a slider

                    // Category and Area (Cuisine)
                    HStack {
                        Text("Category: \(meal.strCategory)")
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        Text("Area: \(meal.strArea)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical)

                    // Ingredients and Measures
                    if !meal.strIngredients.isEmpty {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical, 5)

                        ForEach(0..<meal.strIngredients.count, id: \.self) { index in
                            HStack {
                                Text("•")
                                Text(meal.strMeasures[index])
                                    .font(.body)
                                Text(meal.strIngredients[index])
                                    .font(.body)
                            }
                        }
                    }

                    // Instructions
                    if !meal.strInstructions.isEmpty {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)

                        Text(meal.strInstructions)
                            .font(.body)
                            .padding(.vertical, 5)
                    }

                    // Tags
                    if let tags = meal.strTags, !tags.isEmpty {
                        Text("Tags: \(tags)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.vertical, 5)
                    }

                    Spacer().frame(height: 50)
                }
                .padding()
            }
        }
        .navigationBarItems(leading: backButton)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline) // Ensure compact navigation bar
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(meal.strMeal)
                    .font(.headline)
                    .foregroundColor(.black) // Adjust text color for better contrast
            }
        }
        
    }

    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Back")
                    .foregroundColor(.blue)
            }
        }
    }

    
    func getYouTubeEmbedURL(youtubeLink: String) -> String {
        // Check if it's a standard YouTube link
        if youtubeLink.contains("youtube.com/watch?v="),
           let videoID = youtubeLink.split(separator: "=").last?.split(separator: "&").first {
            return "https://www.youtube.com/embed/\(videoID)"
        }
        // Check if it's a shortened YouTube link (youtu.be)
        else if youtubeLink.contains("youtu.be"),
                let videoID = youtubeLink.split(separator: "/").last?.split(separator: "?").first {
            return "https://www.youtube.com/embed/\(videoID)"
        }
        // Return the original link if it doesn't match the above formats
        return youtubeLink
    }


}

#Preview {
    RecipeDetailPageView(meal: Meal(
        idMeal: "52772",
        strMeal: "Spaghetti Carbonara",
        strCategory: "Pasta",
        strArea: "Italian",
        strInstructions: "Boil the spaghetti. Fry the pancetta. Beat the eggs and mix with cheese. Combine spaghetti, pancetta, and egg mixture. Serve immediately.",
        strMealThumb: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg",
        strYoutube: "https://www.youtube.com/watch?v=3AAdKl1UYZs",
        strIngredients: ["Spaghetti", "Pancetta", "Eggs", "Parmesan Cheese", "Black Pepper"],
        strMeasures: ["200g", "100g", "2", "50g", "to taste"],
        imageUrls: ["https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"]
    ))
}
