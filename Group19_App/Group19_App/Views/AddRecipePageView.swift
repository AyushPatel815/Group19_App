//
//  AddRecipePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//

//import SwiftUI
//
//struct AddRecipePageView: View {
//    @State private var selectedImages: [UIImage] = []
//    @State private var selectedVideoURLs: [URL] = []
//    @State private var showImagePicker = false
//    @State private var showVideoPicker = false
//    
//    // Variables to store user input
//    @State private var ingredients: [String] = [""]
//    @State private var measures: [String] = [""]
//    @State private var strMeal: String = ""
//    @State private var strCategory: String = ""
//    @State private var strArea: String = ""
//    @State private var strInstructions: String = ""
//    @State private var strYoutube: String = ""
//    
//    // Alert and validation
//    @State private var showAlert = false
//    @State private var showValidationError = false
//    @Environment(\.dismiss) var dismiss
//    @Binding var meals: [Meal]
//
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack {
//                    Text("Add your Recipe")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.top, 20)
//                    
//                    // Media (Images and Videos) Section
//                    VStack(alignment: .leading) {
//                        Text("Media (Images & Videos)")
//                            .font(.headline)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                // Display selected images
//                                ForEach(Array(selectedImages.enumerated()), id: \.element) { index, image in
//                                    ZStack(alignment: .topTrailing) {
//                                        Image(uiImage: image)
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 100, height: 100)
//                                            .cornerRadius(8)
//                                        
//                                        // Cross icon to delete the image
//                                        Button(action: {
//                                            selectedImages.remove(at: index)
//                                        }) {
//                                            Image(systemName: "xmark")
//                                                .foregroundColor(.white)
//                                                .bold()
//                                                .clipShape(Circle())
//                                        }
//                                        .offset(x: -10, y: 10)
//                                    }
//                                }
//                                
//                                // Display selected videos
//                                ForEach(Array(selectedVideoURLs.enumerated()), id: \.element) { index, url in
//                                    ZStack(alignment: .topTrailing) {
//                                        Text(url.lastPathComponent)
//                                            .frame(width: 100, height: 100)
//                                            .background(Color.gray.opacity(0.3))
//                                            .cornerRadius(8)
//                                        
//                                        // Cross icon to delete the video
//                                        Button(action: {
//                                            selectedVideoURLs.remove(at: index)
//                                        }) {
//                                            Image(systemName: "xmark")
//                                                .foregroundColor(.white)
//                                                .bold()
//                                                .clipShape(Circle())
//                                        }
//                                        .offset(x: -10, y: 10)
//                                    }
//                                }
//                                
//                                // "+" Button to add media (images/videos)
//                                Button(action: {
//                                    showImagePicker.toggle()
//                                }) {
//                                    Image(systemName: "plus.circle")
//                                        .font(.title2)
//                                        .foregroundColor(.black)
//                                        .frame(width: 100, height: 100)
//                                        .background(Color.gray.opacity(0.3))
//                                        .cornerRadius(8)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    // Other input fields (Meal Name, Category, etc.)
//                    VStack(alignment: .leading) {
//                        Text("Meal Name")
//                            .font(.headline)
//                        TextField("Enter Meal Name", text: $strMeal)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    .padding(.horizontal)
//
//                    VStack(alignment: .leading) {
//                        Text("Category")
//                            .font(.headline)
//                        TextField("Enter Category", text: $strCategory)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    .padding(.horizontal)
//
//                    VStack(alignment: .leading) {
//                        Text("Area")
//                            .font(.headline)
//                        TextField("Enter Area", text: $strArea)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    .padding(.horizontal)
//
//                    VStack(alignment: .leading) {
//                        Text("Instructions")
//                            .font(.headline)
//                        TextEditor(text: $strInstructions)
//                            .frame(height: 100)
//                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
//                    }
//                    .padding(.horizontal)
//                    
//                    // Ingredients and Measures
//                    VStack(alignment: .leading) {
//                        Text("Ingredients and Measures")
//                            .font(.headline)
//                        ForEach(0..<ingredients.count, id: \.self) { index in
//                            HStack {
//                                TextField("Ingredient \(index + 1)", text: $ingredients[index])
//                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                                    .frame(width: 150)
//                                TextField("Measure \(index + 1)", text: $measures[index])
//                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                                    .frame(width: 100)
//                            }
//                        }
//                        // "+" Button to add more ingredients and measures
//                        Button(action: {
//                            ingredients.append("")
//                            measures.append("")
//                        }) {
//                            HStack {
//                                Image(systemName: "plus.circle")
//                                    .foregroundColor(.green)
//                                Text("Add Ingredient")
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    // YouTube Link
//                    VStack(alignment: .leading) {
//                        Text("YouTube Link")
//                            .font(.headline)
//                        TextField("Enter YouTube Link", text: $strYoutube)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    .padding(.horizontal)
//
//                    Spacer()
//                    
//                    // Post and Cancel buttons
//                    HStack {
//                        Button(action: {
//                            // Reset all fields when Cancel is clicked
//                            resetFields()
//                        }) {
//                            Text("Cancel")
//                                .font(.headline)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.red)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        
//                        Button(action: {
//                            // Check if all required fields are filled
//                            if validateInputs() {
//                                // Trigger the confirmation alert if inputs are valid
//                                showAlert = true
//                            } else {
//                                // Show validation error alert if any required field is empty
//                                showValidationError = true
//                            }
//                        }) {
//                            Text("Post")
//                                .font(.headline)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.green)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        // Alert to confirm the post
//                        .alert("Confirm Post", isPresented: $showAlert) {
//                            Button("Yes", role: .destructive) {
//                                postRecipe()  // Call to save the recipe
//                                resetFields()  // Clear all fields after successful post
//                                dismiss()  // Dismiss the view
//                            }
//                            Button("Cancel", role: .cancel) {
//                                // Do nothing, just close the alert
//                            }
//                        } message: {
//                            Text("Are you sure you want to post this recipe?")
//                        }
//                        // Alert for validation error
//                        .alert("Error", isPresented: $showValidationError) {
//                            Button("OK", role: .cancel) { }
//                        } message: {
//                            Text("Meal Name, Category, Area, and Instructions are required fields.")
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 80)
//                }
//                .padding(.top)
//            }
//            .navigationTitle("")
//            .navigationBarHidden(true)
//            .sheet(isPresented: $showImagePicker) {
//                ImagePickerView(selectedImages: $selectedImages, selectedVideoURLs: $selectedVideoURLs)
//            }
//        }
//    }
//    
//    // Reset all fields
//    func resetFields() {
//        ingredients = [""]
//        measures = [""]
//        selectedImages = []
//        selectedVideoURLs = []
//        strMeal = ""
//        strCategory = ""
//        strArea = ""
//        strInstructions = ""
//        strYoutube = ""
//    }
//
//    // Post the recipe and save to the meals list
//    // Inside the postRecipe function in AddRecipePageView
//    func postRecipe() {
//        let newMeal = Meal(
//            idMeal: UUID().uuidString,  // Generate a unique ID for user-added meals
//            strMeal: strMeal,
//            strCategory: strCategory,
//            strArea: strArea,
//            strInstructions: strInstructions,
//            strMealThumb: "",  // Handle image saving logic here
//            strYoutube: strYoutube,
//            strIngredients: ingredients.filter { !$0.isEmpty },
//            strMeasures: measures.filter { !$0.isEmpty },
//            imagesData: selectedImages.map { $0.pngData()! },  // Save all images as Data
//            isUserAdded: true  // Mark this meal as user-added
//        )
//        
//        // Add the new recipe to the meals array
//        meals.append(newMeal)
//    }
//
//    
//    // Validate required fields
//    func validateInputs() -> Bool {
//        return !strMeal.isEmpty && !strCategory.isEmpty && !strArea.isEmpty && !strInstructions.isEmpty
//    }
//}
//
//
//// Helper view to create input sections with a "+" icon, list items, and edit/delete functionality
//struct AddRecipeListField: View {
//    var title: String
//    @Binding var items: [String]
//    var onAdd: () -> Void
//    var onEdit: (Int) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text(title)
//                    .font(.headline)
//                Spacer()
//                Button(action: onAdd) {
//                    Image(systemName: "plus.circle")
//                        .font(.title2)
//                        .foregroundColor(.black)
//                }
//            }
//            .padding(.vertical, 10)
//            
//            Divider()
//            
//            // List of items with edit and delete options
//            ForEach(items.indices, id: \.self) { index in
//                HStack {
//                    Text(items[index])
//                        .font(.body)
//                        .padding(.leading, 5)
//                    Spacer()
//                    Button(action: {
//                        onEdit(index)
//                    }) {
//                        Image(systemName: "pencil")
//                            .foregroundColor(.blue)
//                    }
//                    Button(action: {
//                        items.remove(at: index)
//                    }) {
//                        Image(systemName: "trash")
//                            .foregroundColor(.red)
//                    }
//                }
//                .padding(.vertical, 5)
//            }
//        }
//        .padding(.horizontal)
//    }
//}
//
//// Enum to track the field being edited
//enum FieldType {
//    case ingredients, descriptions, cookingTimes, recipeTypes
//}
//
//// New view for adding details with a Save button
//struct AddDetailView: View {
//    var title: String
//    @Binding var text: String
//    var onSave: (String) -> Void
//    
//    @Environment(\.dismiss) var dismiss
//    @State private var viewTitle: String = "" // State to control the title rendering
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            TextEditor(text: $text)
//                .padding()
//                .border(Color.gray, width: 1)
//                .frame(height: 550)
//
//            Spacer()
//
//            Button(action: {
//                onSave(text)
//                dismiss()
//            }) {
//                Text("Save")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: 100)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//            }
//            .padding(.bottom, 80)
//            .padding(.leading,150)
//        }
//        .onAppear {
//            viewTitle = "Add \(title)" // Assign the title to the state on appear
//        }
//        .navigationTitle(viewTitle)  // Use the state variable for the title
//        .navigationBarTitleDisplayMode(.inline)
//        .padding()
//    }
//}
//
//#Preview {
//    AddRecipePageView(meals: .constant([]))
//}



import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct AddRecipePageView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
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
    @State private var isUploading = false
    @Environment(\.dismiss) var dismiss
    @Binding var meals: [Meal]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Add your Recipe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
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
                
                // Post and Cancel buttons
                HStack {
                    Button(action: {
                        resetFields()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        if validateInputs() {
                            showAlert = true
                        } else {
                            showValidationError = true
                        }
                    }) {
                        if isUploading {
                            ProgressView()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        } else {
                            Text("Post")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .alert("Error", isPresented: $showValidationError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Meal Name, Category, Area, and Instructions are required.")
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
                .padding()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(selectedImages: $selectedImages, selectedVideoURLs: .constant([]))
            }
        }
    }

    // Input field helper
    func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField("Enter \(title)", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
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
        selectedImages = []
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
            strIngredients: ingredients.filter { !$0.isEmpty },
            strMeasures: measures.filter { !$0.isEmpty },
            isUserAdded: true
        )

        isUploading = true // Show a loading indicator

        FirestoreHelper.shared.saveRecipeWithMedia(recipe: newMeal, images: selectedImages) { error in
            isUploading = false // Hide the loading indicator
            if let error = error {
                print("Error posting recipe: \(error)")
            } else {
                print("Recipe posted successfully.")
                resetFields()
                dismiss()
            }
        }
    }


}

#Preview {
    AddRecipePageView(meals: .constant([]))
}
