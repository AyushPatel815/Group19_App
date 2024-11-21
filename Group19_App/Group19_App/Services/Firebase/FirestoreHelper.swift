//
//  FirestoreHelper.swift
//  Group19_App
//
//  Created by Ayush Patel on 11/20/24.
//



import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirestoreHelper {
    static let shared = FirestoreHelper()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // Save Recipe to Firestore (specific to the authenticated user)
    func saveRecipe(recipe: Meal, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let recipeData: [String: Any] = [
            "idMeal": recipe.idMeal,
            "strMeal": recipe.strMeal,
            "strCategory": recipe.strCategory,
            "strArea": recipe.strArea,
            "strInstructions": recipe.strInstructions,
            "strMealThumb": recipe.strMealThumb,
            "strTags": recipe.strTags ?? "",
            "strYoutube": recipe.strYoutube,
            "strIngredients": recipe.strIngredients,
            "strMeasures": recipe.strMeasures,
            "addedBy": user.uid,
            "timestamp": Timestamp(date: Date())
        ]

        // Save recipe to user's `savedRecipes` subcollection
        db.collection("users").document(user.uid).collection("savedRecipes").document(recipe.idMeal).setData(recipeData) { error in
            completion(error)
        }
    }
    
    
    func saveRecipeWithMedia(recipe: Meal, images: [UIImage], completion: @escaping (Error?) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
                return
            }

            let recipeID = recipe.idMeal
            var uploadedImageURLs: [String] = []
            let uploadGroup = DispatchGroup()

            // Upload each image to Firebase Storage
            for image in images {
                uploadGroup.enter()
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    print("Error converting image to JPEG data.")
                    uploadGroup.leave()
                    continue
                }

                let imageRef = storage.reference().child("users/\(user.uid)/recipes/\(recipeID)/\(UUID().uuidString).jpg")
                imageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        print("Error uploading image: \(error)")
                        uploadGroup.leave()
                        return
                    }
                    imageRef.downloadURL { url, error in
                        if let url = url {
                            uploadedImageURLs.append(url.absoluteString)
                        } else if let error = error {
                            print("Error getting download URL: \(error)")
                        }
                        uploadGroup.leave()
                    }
                }
            }

            // Wait for all uploads to complete
            uploadGroup.notify(queue: .main) {
                var recipeData: [String: Any] = [
                    "idMeal": recipeID,
                    "strMeal": recipe.strMeal,
                    "strCategory": recipe.strCategory,
                    "strArea": recipe.strArea,
                    "strInstructions": recipe.strInstructions,
                    "strIngredients": recipe.strIngredients,
                    "strMeasures": recipe.strMeasures,
                    "addedBy": user.uid,
                    "timestamp": Timestamp(date: Date())
                ]

                // Add uploaded image URLs to recipe data
                if !uploadedImageURLs.isEmpty {
                    recipeData["images"] = uploadedImageURLs
                }

                // Save recipe to Firestore
                self.db.collection("users").document(user.uid).collection("recipes").document(recipeID).setData(recipeData) { error in
                    completion(error)
                }
            }
        }

    // Fetch Saved Recipes for the Logged-in User
    func fetchSavedRecipes(completion: @escaping ([Meal]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        db.collection("users").document(user.uid).collection("savedRecipes").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            let recipes = snapshot?.documents.compactMap { document -> Meal? in
                let data = document.data()
                return Meal(
                    idMeal: data["idMeal"] as? String ?? UUID().uuidString,
                    strMeal: data["strMeal"] as? String ?? "Unknown",
                    strCategory: data["strCategory"] as? String ?? "Unknown",
                    strArea: data["strArea"] as? String ?? "Unknown",
                    strInstructions: data["strInstructions"] as? String ?? "",
                    strMealThumb: data["strMealThumb"] as? String ?? "",
                    strTags: data["strTags"] as? String,
                    strYoutube: data["strYoutube"] as? String ?? "",
                    strIngredients: data["strIngredients"] as? [String] ?? [],
                    strMeasures: data["strMeasures"] as? [String] ?? []
                )
            }
            completion(recipes, nil)
        }
    }

    // Fetch All Public Recipes (Optional)
    func fetchAllRecipes(completion: @escaping ([Meal]?, Error?) -> Void) {
        db.collection("recipes").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            let recipes = snapshot?.documents.compactMap { document -> Meal? in
                let data = document.data()
                return Meal(
                    idMeal: data["idMeal"] as? String ?? UUID().uuidString,
                    strMeal: data["strMeal"] as? String ?? "Unknown",
                    strCategory: data["strCategory"] as? String ?? "Unknown",
                    strArea: data["strArea"] as? String ?? "Unknown",
                    strInstructions: data["strInstructions"] as? String ?? "",
                    strMealThumb: data["strMealThumb"] as? String ?? "",
                    strTags: data["strTags"] as? String,
                    strYoutube: data["strYoutube"] as? String ?? "",
                    strIngredients: data["strIngredients"] as? [String] ?? [],
                    strMeasures: data["strMeasures"] as? [String] ?? []
                )
            }
            completion(recipes, nil)
        }
    }
    
    
    func fetchAllUserRecipes(completion: @escaping ([Meal]) -> Void) {
        db.collectionGroup("recipes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all user recipes: \(error)")
                completion([])
                return
            }

            let recipes = snapshot?.documents.compactMap { document -> Meal? in
                let data = document.data()
                return Meal(
                    idMeal: data["idMeal"] as? String ?? UUID().uuidString,
                    strMeal: data["strMeal"] as? String ?? "Unknown",
                    strCategory: data["strCategory"] as? String ?? "Unknown",
                    strArea: data["strArea"] as? String ?? "Unknown",
                    strInstructions: data["strInstructions"] as? String ?? "",
                    strMealThumb: data["strMealThumb"] as? String ?? "",
                    strIngredients: data["strIngredients"] as? [String] ?? [],
                    strMeasures: data["strMeasures"] as? [String] ?? [],
                    isUserAdded: true
                )
            }
            completion(recipes ?? [])
        }
    }

    
    func deleteMeal(_ meal: Meal, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let recipeRef = db.collection("users").document(userID).collection("recipes").document(meal.idMeal)

        // Remove from Firestore
        recipeRef.delete { error in
            completion(error) // Notify the caller of success or failure
        }
    }

    
    func listenForUserRecipes(completion: @escaping ([Meal]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            completion([])
            return
        }

        db.collection("users").document(userID).collection("recipes")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for user recipes: \(error)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }

                let recipes = documents.compactMap { document -> Meal? in
                    let data = document.data()
                    return Meal(
                        idMeal: data["idMeal"] as? String ?? UUID().uuidString,
                        strMeal: data["strMeal"] as? String ?? "Unknown",
                        strCategory: data["strCategory"] as? String ?? "Unknown",
                        strArea: data["strArea"] as? String ?? "Unknown",
                        strInstructions: data["strInstructions"] as? String ?? "",
                        strMealThumb: data["strMealThumb"] as? String ?? "",
                        strIngredients: data["strIngredients"] as? [String] ?? [],
                        strMeasures: data["strMeasures"] as? [String] ?? [],
                        isUserAdded: true
                    )
                }

                completion(recipes)
            }
    }

    
    func listenForAllRecipes(existingRecipes: [Meal], completion: @escaping ([Meal]) -> Void) {
        db.collectionGroup("recipes").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening for all recipes: \(error)")
                completion([])
                return
            }

            let recipes = snapshot?.documents.compactMap { document -> Meal? in
                let data = document.data()
                return Meal(
                    idMeal: data["idMeal"] as? String ?? UUID().uuidString,
                    strMeal: data["strMeal"] as? String ?? "Unknown",
                    strCategory: data["strCategory"] as? String ?? "Unknown",
                    strArea: data["strArea"] as? String ?? "Unknown",
                    strInstructions: data["strInstructions"] as? String ?? "",
                    strMealThumb: data["strMealThumb"] as? String ?? "",
                    strIngredients: data["strIngredients"] as? [String] ?? [],
                    strMeasures: data["strMeasures"] as? [String] ?? [],
                    isUserAdded: true
                )
            }

            // Filter out recipes that already exist in `existingRecipes`
            let uniqueRecipes = recipes?.filter { newRecipe in
                !existingRecipes.contains { $0.idMeal == newRecipe.idMeal }
            }

            completion(uniqueRecipes ?? [])
        }
    }




}
