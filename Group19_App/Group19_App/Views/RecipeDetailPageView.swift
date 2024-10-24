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
        return WKWebView()
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
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // Image and YouTube link slider
                    TabView {
                        // Display all images if available
                        if let imageDataArray = meal.imagesData, !imageDataArray.isEmpty {
                            ForEach(Array(imageDataArray.enumerated()), id: \.offset) { index, imageData in
                                if let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: 300)
                                        .cornerRadius(10)
                                        .padding()
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
                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle()) // Make it look like a slider

                    // Category and Area (Cuisine)
                    HStack {
                        HStack {
                            Text("Category:")
                                .font(.custom("Avenir Next", size: 20))
                                .fontWeight(.bold)
                            Text("\(meal.strCategory)")
                                .font(.custom("Avenir Next", size: 20))
                        }
                        Spacer()

                        HStack {
                            Text("Area:")
                                .font(.custom("Avenir Next", size: 18))
                                .fontWeight(.bold)
                            Text("\(meal.strArea)")
                                .font(.custom("Avenir Next", size: 18))
                        }
                    }
                    .padding(.bottom, 5)

                    // Ingredients and Measures
                    Text("Ingredients")
                        .font(.custom("Avenir Next", size: 25))
                        .fontWeight(.bold)
                        .padding(.top, 5)

                    ForEach(0..<meal.strIngredients.count, id: \.self) { index in
                        HStack {
                            Text("•") // Adding the bullet point
                            Text("\(meal.strMeasures[index])")
                                .font(.custom("Avenir Next", size: 18))
                            Text(meal.strIngredients[index])
                                .font(.custom("Avenir Next", size: 18))
                        }
                    }

                    // Instructions
                    Text("Instructions")
                        .font(.custom("Avenir Next", size: 25))
                        .fontWeight(.bold)
                        .padding(.top, 10)

                    Text(meal.strInstructions)
                        .font(.custom("Avenir Next", size: 18))
                        .padding(.top, 5)

                    // Tags
                    if let tags = meal.strTags {
                        Text("Tags: \(tags)")
                            .font(.custom("Avenir Next", size: 14))
                            .fontWeight(.bold)
                            .padding(.top, 5)
                    }
                    Spacer()
                        .frame(height: 50)
                }
                .padding() // Padding for content within the scroll view
            }
            .padding(.bottom,40)
        }
        .navigationBarItems(leading: backButton)
        .navigationBarBackButtonHidden()
        .navigationBarTitle(meal.strMeal, displayMode: .inline)
        .toolbarBackground(Color.yellow, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(meal.strMeal)
                        .font(.custom("Avenir Next", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineLimit(nil) // Allow unlimited lines
                        .multilineTextAlignment(.center) // Center align the text
                }
            }
        }
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss() // Dismiss the current view
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .bold()
                Text("Back")
                    .foregroundColor(.blue)
                    .bold()
            }
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
