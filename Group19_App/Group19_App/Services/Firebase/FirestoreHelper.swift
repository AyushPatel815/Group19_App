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
    static let shared = FirestoreHelper()   // Singleton instance
    private let db = Firestore.firestore()    // Firestore reference
    private let storage = Storage.storage()   // Firebase Storage reference
    
    private init() {}   // Private initializer to enforce singleton pattern
    
    
    // Save Recipe to Firestore (specific to the authenticated user)
    func saveRecipe(recipe: Meal, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        // Prepare the recipe data for Firestore
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
    
    
    // Save Recipe with Media (Images)
    func saveRecipeWithMedia(recipe: Meal, images: [UIImage], completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let recipeID = recipe.idMeal    // Unique ID for the recipe
        var uploadedImageURLs: [String] = []    // Store uploaded image URLs
        let uploadGroup = DispatchGroup()   // Dispatch group for managing uploads
        
        // Loop through images to upload each one to Firebase Storage
        for (index, image) in images.enumerated() {
            uploadGroup.enter()
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Error converting image \(index) to JPEG data.")
                uploadGroup.leave()
                continue
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg" // Set correct Content-Type for image
            
            let imageRef = storage.reference().child("users/\(userID)/recipes/\(recipeID)/\(UUID().uuidString).jpg")
            imageRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    print("Error uploading image \(index): \(error)")
                    
                    uploadGroup.leave()
                    return
                }
                imageRef.downloadURL { url, error in
                    if let url = url {
                        uploadedImageURLs.append(url.absoluteString)
                    } else {
                        print("Error getting download URL for image \(index): \(String(describing: error))")
                    }
                    uploadGroup.leave()
                }
            }
        }
        
        // Notify when all image uploads are complete
        uploadGroup.notify(queue: .main) {
            var recipeData: [String: Any] = [
                "idMeal": recipeID,
                "strMeal": recipe.strMeal,
                "strCategory": recipe.strCategory,
                "strArea": recipe.strArea,
                "strInstructions": recipe.strInstructions,
                "strYoutube": recipe.strYoutube,
                "strIngredients": recipe.strIngredients,
                "strMeasures": recipe.strMeasures,
                "addedBy": userID,
                "timestamp": Timestamp(date: Date())
            ]
            
            if !uploadedImageURLs.isEmpty {
                recipeData["images"] = uploadedImageURLs
            }else {
                print("No images uploaded for recipe: \(recipe.strMeal)")
            }
            
            self.db.collection("users").document(userID).collection("recipes").document(recipeID).setData(recipeData) { error in
                if let error = error {
                    print("Error saving recipe to Firestore: \(error)")
                } else {
                    print("Recipe saved successfully to Firestore.")
                }
                completion(error)
            }
        }
        
    }
    
    // Fetch saved recipes for the authenticated user
    func fetchSavedRecipes(completion: @escaping ([Meal]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated.")
            completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        // Fetch recipes from the `savedRecipes` subcollection
        db.collection("users").document(user.uid).collection("savedRecipes").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let recipes = snapshot?.documents.compactMap { document -> Meal? in
                let data = document.data()
                return Meal(
                    idMeal: data["idMeal"] as? String ?? UUID().uuidString, // Fetch idMeal from Firestore
                    strMeal: data["strMeal"] as? String ?? "Unknown",  // Fetch Meal name from Firestore
                    strCategory: data["strCategory"] as? String ?? "Unknown",   // Fetch Meal Category from Firestore
                    strArea: data["strArea"] as? String ?? "Unknown",    // Fetch Mela Area from Firestore
                    strInstructions: data["strInstructions"] as? String ?? "",    // Fetch Meal Instructions from Firestore
                    strMealThumb: data["strMealThumb"] as? String ?? "",    // Fetch MealThumb from Firestore
                    strYoutube: data["strYoutube"] as? String ?? "",    // Fetch Youtbube video URL from Firestore
                    strIngredients: data["strIngredients"] as? [String] ?? [],    // Fetch Meal Ingredients from Firestore
                    strMeasures: data["strMeasures"] as? [String] ?? [],   // Fetch Ingredients measure from Firestore
                    imageUrls: data["images"] as? [String] ?? [] // Fetch images from Firestore
                )
            }
            print("Recipes Decoded: \(recipes ?? [])") // Log decoded recipes
            
            completion(recipes, nil)
        }
    }
    
    // Fetch all recipes across users
    func fetchAllUserRecipes(completion: @escaping ([Meal]) -> Void) {
        print("fetchAllUserRecipes called")
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated. Ensure you're logged in.")
            completion([])
            return
        }
        print("User authenticated with ID: \(user.uid)")
        
        db.collectionGroup("recipes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all user recipes: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil. No documents found.")
                completion([])
                return
            }
            
            print("Number of documents fetched: \(snapshot.documents.count)")
            
            let recipes = snapshot.documents.compactMap { document -> Meal? in
                let data = document.data()
                
                // Safeguard against missing fields
                guard let idMeal = data["idMeal"] as? String,
                      let strMeal = data["strMeal"] as? String else {
                    print("Missing required fields in document: \(document.documentID)")
                    return nil
                }
                
                let strYoutube = data["strYoutube"] as? String ?? "" // Explicitly handle YouTube link
                
                return Meal(
                    idMeal: idMeal,
                    strMeal: strMeal,
                    strCategory: data["strCategory"] as? String ?? "Unknown",
                    strArea: data["strArea"] as? String ?? "Unknown",
                    strInstructions: data["strInstructions"] as? String ?? "",
                    strMealThumb: data["strMealThumb"] as? String ?? "",
                    strYoutube: data["strYoutube"] as? String ?? "",
                    strIngredients: data["strIngredients"] as? [String] ?? [],
                    strMeasures: data["strMeasures"] as? [String] ?? [],
                    imageUrls: data["images"] as? [String] ?? [],
                    isUserAdded: true
                )
            }
            
            print("Recipes Decoded: \(recipes)") // Log decoded recipes
            completion(recipes)
        }
    }
    
    // Helper function to delete Firestore document
    private func deleteFirestoreDocument(_ documentRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        documentRef.delete { error in
            if let error = error {
                print("Error deleting Firestore document: \(error)")
            } else {
                print("Successfully deleted Firestore document.")
            }
            completion(error)
        }
    }
    
    // Helper function to extract Firebase Storage path from URL
    private func getStoragePath(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let path = urlComponents.path.split(separator: "/").dropFirst(2).joined(separator: "/").removingPercentEncoding else {
            return nil
        }
        return path
    }
    
    // Live update of User added recipe
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
                        strYoutube: data["strYoutube"] as? String ?? "",
                        strIngredients: data["strIngredients"] as? [String] ?? [],
                        strMeasures: data["strMeasures"] as? [String] ?? [],
                        imageUrls: data["images"] as? [String],
                        isUserAdded: true
                    )
                }
                
                completion(recipes)
            }
    }
    
    // Live update of All the recipe in API and Firebase
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
    
    // Fetching saved recipe for individual user
    func fetchSavedMeals(for userID: String, completion: @escaping ([Meal]) -> Void) {
        let db = Firestore.firestore()
        let recipesRef = db.collection("users").document(userID).collection("savedRecipes")
        
        recipesRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching saved recipes: \(error)")
                completion([])
                return
            }
            
            let fetchedMeals: [Meal] = snapshot?.documents.compactMap { document in
                try? document.data(as: Meal.self)
            } ?? []
            
            completion(fetchedMeals)
        }
    }
    
    // Delete a meal from Firestore
    func deleteMeal(_ meal: Meal, for userID: String, inCollection collection: String = "recipes", hasMedia: Bool = false, completion: @escaping (Error?) -> Void) {
        let recipeRef = db.collection("users").document(userID).collection(collection).document(meal.idMeal)
        let storageRef = storage.reference().child("users/\(userID)/recipes/\(meal.idMeal)")
        
        if hasMedia {
            // If media files exist, delete them from Firebase Storage first
            storageRef.listAll { result, error in
                if let error = error {
                    print("Error listing files in storage: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                guard let items = result?.items, !items.isEmpty else {
                    print("No files found in storage for \(meal.idMeal)")
                    // Proceed with Firestore document deletion even if no files are found
                    recipeRef.delete { error in
                        if let error = error {
                            print("Error deleting Firestore document: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("Successfully deleted recipe document (no media files found).")
                            completion(nil)
                        }
                    }
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                items.forEach { item in
                    dispatchGroup.enter()
                    item.delete { error in
                        if let error = error {
                            print("Error deleting file \(item.name): \(error.localizedDescription)")
                        } else {
                            print("Deleted file: \(item.name)")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    // After all media is deleted, remove the Firestore document
                    recipeRef.delete { error in
                        if let error = error {
                            print("Error deleting Firestore document: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted recipe and associated media.")
                        }
                        completion(error)
                    }
                }
            }
        } else {
            // If no media, directly delete the Firestore document
            recipeRef.delete { error in
                if let error = error {
                    print("Error deleting Firestore document: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted recipe document.")
                }
                completion(error)
            }
        }
    }
    
    func deleteFromSavedRecipes(_ meal: Meal, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collectionGroup("savedRecipes")
            .whereField("idMeal", isEqualTo: meal.idMeal)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching saved recipes for deletion: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No saved recipes found for deletion.")
                    completion(false)
                    return
                }
                
                let batch = db.batch()
                
                for document in documents {
                    print("Deleting document: \(document.documentID) from savedRecipes")
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("Error committing batch deletion: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Successfully deleted from saved recipes.")
                        completion(true)
                    }
                }
            }
    }
    
    func deleteMealFromAllLocations(_ meal: Meal, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        // Check if the meal is in saved recipes
        isMealSaved(meal) { isSaved in
            if isSaved {
                // If the meal is saved, delete from savedRecipes first
                self.deleteFromSavedRecipes(meal) { success in
                    if success {
                        // After deleting from savedRecipes, delete from recipes
                        self.deleteMeal(meal, for: userID, hasMedia: true) { error in
                            if let error = error {
                                print("Failed to delete meal from recipes: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Meal successfully deleted from all locations.")
                                completion(true)
                            }
                        }
                    } else {
                        print("Failed to delete meal from savedRecipes.")
                        completion(false)
                    }
                }
            } else {
                // If the meal is not in savedRecipes, delete directly from recipes
                self.deleteMeal(meal, for: userID, hasMedia: true) { error in
                    if let error = error {
                        print("Failed to delete meal from recipes: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Meal successfully deleted from recipes.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    // Check if a meal is saved in the user's savedRecipes
    func isMealSaved(_ meal: Meal, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let savedRecipeRef = db.collection("users").document(userID).collection("savedRecipes").document(meal.idMeal)
        
        savedRecipeRef.getDocument { document, error in
            if let error = error {
                print("Error checking saved meal: \(error.localizedDescription)")
                completion(false)
            } else if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    
}
