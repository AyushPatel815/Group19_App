//
//  AddRecipePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct AddRecipePageView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedVideos: [URL] = [] // Track selected video URLs
    
    // User input variables
    @State private var ingredients: [String] = [""]
    @State private var measures: [String] = [""]
    @State private var strMeal: String = ""
    @State private var strCategory: String = ""
    @State private var strArea: String = ""
    @State private var strInstructions: String = ""
    @State private var strYoutube: String = ""
    
    // Alert and validation
    @State private var showAlert = false
    @State private var showValidationError = false
    @State private var validationErrorMessage: String = "" // Store validation error message
    @State private var isUploading = false
    @Environment(\.dismiss) var dismiss
    @Binding var meals: [Meal]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
//                    Text("Add your Recipe")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.top, 20)
                    
                    // Media Section
                    VStack(alignment: .leading) {
                        Text("Images")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Display selected images
                                ForEach(Array(selectedImages.enumerated()), id: \.element) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                        
                                        // Cross icon to delete the image
                                        Button(action: {
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .offset(x: -10, y: 10)
                                    }
                                }
                                
                                // "+" Button to add media
                                Button(action: {
                                    showImagePicker.toggle()
                                }) {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Input fields
                    Group {
                        inputField(title: "Meal Name", text: $strMeal)
                        inputField(title: "Category", text: $strCategory)
                        inputField(title: "Area", text: $strArea)
                        
                        VStack(alignment: .leading) {
                            Text("Instructions")
                                .font(.headline)
                            TextEditor(text: $strInstructions)
                                .frame(height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .padding(.horizontal)
                        }
                        
                        ingredientsSection()
                        
                        inputField(title: "YouTube Link", text: $strYoutube)
                    }
                    
                }
                .padding()
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerView(selectedImages: $selectedImages, selectedVideoURLs: $selectedVideos)
                }
            }
        }
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
        .navigationBarItems(
                        leading: Button("Cancel") {
                            resetFields()
                            dismiss()
                        }
                        .foregroundColor(.red),
                        
                        trailing: Button("Post") {
                            validateAndPost()
                        }
                        .foregroundColor(.blue)
                        .disabled( isUploading)
                    )
        .navigationTitle("Add Recipe")
                    .alert("Error", isPresented: $showValidationError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(validationErrorMessage)
                    }
                    .alert("Confirm Post", isPresented: $showAlert) {
                        Button("Yes", role: .destructive) {
                            postRecipe()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to post this recipe?")
                    }
    }

    // Input field helper
    func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField("Enter \(title)", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
        }
    }
    
    // Ingredients section
    func ingredientsSection() -> some View {
        VStack(alignment: .leading) {
            Text("Ingredients and Measures")
                .font(.headline)
            ForEach(0..<ingredients.count, id: \.self) { index in
                HStack {
                    TextField("Ingredient \(index + 1)", text: $ingredients[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                    TextField("Measure \(index + 1)", text: $measures[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
            Button(action: {
                ingredients.append("")
                measures.append("")
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.green)
                    Text("Add Ingredient")
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Reset fields
    func resetFields() {
        strMeal = ""
        strCategory = ""
        strArea = ""
        strInstructions = ""
        ingredients = [""]
        measures = [""]
        strYoutube = ""
        selectedImages = []
    }
    
    
    // Validate inputs and handle errors
    func validateAndPost() {
        // Validation logic
        if selectedImages.count > 5 {
            validationErrorMessage = "You can select at most 5 images."
            showValidationError = true
            return
        }
        
        if selectedVideos.count > 2 {
            validationErrorMessage = "You can select at most 2 videos."
            showValidationError = true
            return
        }
        
        if strMeal.isEmpty {
            validationErrorMessage = "Meal Name is required."
            showValidationError = true
            return
        }
        
        if strMeal.count > 20 {
            validationErrorMessage = "Meal Name should be no more than 20 characters."
            showValidationError = true
            return
        }
        
        if strCategory.isEmpty {
            validationErrorMessage = "Category is required."
            showValidationError = true
            return
        }
        
        if strCategory.count > 15 {
            validationErrorMessage = "Category should be no more than 15 characters."
            showValidationError = true
            return
        }
        
        if strArea.isEmpty {
            validationErrorMessage = "Area is required."
            showValidationError = true
            return
        }
        
        if strArea.count > 15 {
            validationErrorMessage = "Area should be no more than 15 characters."
            showValidationError = true
            return
        }
        
        if strInstructions.isEmpty {
            validationErrorMessage = "Instructions are required."
            showValidationError = true
            return
        }
        
        if ingredients.allSatisfy({ $0.isEmpty }) {
            validationErrorMessage = "At least one ingredient is required."
            showValidationError = true
            return
        }
        
        if measures.allSatisfy({ $0.isEmpty }) {
            validationErrorMessage = "Ingredient measure is required."
            showValidationError = true
            return
        }
        
        // If all validations pass, proceed to show confirmation alert
        showAlert = true
    }

    
    // Validate inputs
    func validateInputs() -> Bool {
        return !strMeal.isEmpty && !strCategory.isEmpty && !strArea.isEmpty && !strInstructions.isEmpty
    }
    
    // Post recipe to Firebase
    func postRecipe() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }

        let newMeal = Meal(
            idMeal: UUID().uuidString,
            strMeal: strMeal,
            strCategory: strCategory,
            strArea: strArea,
            strInstructions: strInstructions,
            strYoutube: strYoutube,
            strIngredients: ingredients.filter { !$0.isEmpty },
            strMeasures: measures.filter { !$0.isEmpty },
            isUserAdded: true
        )
        
        for (index, image) in selectedImages.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    print("Image \(index) size: \(imageData.count) bytes")
                } else {
                    print("Failed to convert image \(index) to JPEG data.")
                }
        }

        isUploading = true // Show a loading indicator

        FirestoreHelper.shared.saveRecipeWithMedia(recipe: newMeal, images: selectedImages) { error in
            isUploading = false // Hide the loading indicator
            if let error = error {
                print("Error posting recipe: \(error)")
            } else {
                print("Recipe posted successfully.")
                
                Task {
                                await FirestoreHelper.shared.fetchAllUserRecipes { updatedRecipes in
                                    DispatchQueue.main.async {
                                        self.meals = updatedRecipes
                                    }
                                }
                            }
                
                resetFields()
                dismiss()
            }
        }
    }


}

#Preview {
    AddRecipePageView(meals: .constant([]))
}
