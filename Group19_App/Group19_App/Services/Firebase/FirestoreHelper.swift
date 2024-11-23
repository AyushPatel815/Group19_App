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
    
    
//    func saveRecipeWithMedia(recipe: Meal, images: [UIImage], completion: @escaping (Error?) -> Void) {
//            guard let user = Auth.auth().currentUser else {
//                completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
//                return
//            }
//
//            let recipeID = recipe.idMeal
//            var uploadedImageURLs: [String] = []
//            let uploadGroup = DispatchGroup()
//
//            // Upload each image to Firebase Storage
//            for image in images {
//                uploadGroup.enter()
//                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//                    print("Error converting image to JPEG data.")
//                    uploadGroup.leave()
//                    continue
//                }
//
//                let imageRef = storage.reference().child("users/\(user.uid)/recipes/\(recipeID)/\(UUID().uuidString).jpg")
//                imageRef.putData(imageData, metadata: nil) { _, error in
//                    if let error = error {
//                        print("Error uploading image: \(error)")
//                        uploadGroup.leave()
//                        return
//                    }
//                    imageRef.downloadURL { url, error in
//                        if let url = url {
//                            uploadedImageURLs.append(url.absoluteString)
//                        } else if let error = error {
//                            print("Error getting download URL: \(error)")
//                        }
//                        uploadGroup.leave()
//                    }
//                }
//            }
//
//            // Wait for all uploads to complete
//            uploadGroup.notify(queue: .main) {
//                var recipeData: [String: Any] = [
//                    "idMeal": recipeID,
//                    "strMeal": recipe.strMeal,
//                    "strCategory": recipe.strCategory,
//                    "strArea": recipe.strArea,
//                    "strInstructions": recipe.strInstructions,
//                    "strIngredients": recipe.strIngredients,
//                    "strMeasures": recipe.strMeasures,
//                    "addedBy": user.uid,
//                    "timestamp": Timestamp(date: Date())
//                ]
//
//                // Add uploaded image URLs to recipe data
//                if !uploadedImageURLs.isEmpty {
//                    recipeData["images"] = uploadedImageURLs
//                }
//
//                // Save recipe to Firestore
//                self.db.collection("users").document(user.uid).collection("recipes").document(recipeID).setData(recipeData) { error in
//                    completion(error)
//                }
//            }
//        }
    
    
//    func saveRecipeWithMedia(recipe: Meal, images: [UIImage], completion: @escaping (Error?) -> Void) {
//        guard let userID = Auth.auth().currentUser?.uid else {
//            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
//            return
//        }
//
//        let recipeID = recipe.idMeal
//        var uploadedImageURLs: [String] = []
//        let uploadGroup = DispatchGroup()
//
//        for (index, image) in images.enumerated() {
//            uploadGroup.enter()
//            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//                print("Error converting image \(index) to JPEG data.")
//                uploadGroup.leave()
//                continue
//            }
//
//            print("Uploading image \(index) with size \(imageData.count) bytes")
//
//            let imageRef = storage.reference().child("users/\(userID)/recipes/\(recipeID)/\(UUID().uuidString).jpg")
//            imageRef.putData(imageData, metadata: nil) { _, error in
//                if let error = error {
//                    print("Error uploading image \(index): \(error)")
//                    uploadGroup.leave()
//                    return
//                }
//                imageRef.downloadURL { url, error in
//                    if let url = url {
//                        print("Image \(index) uploaded successfully: \(url.absoluteString)")
//                        uploadedImageURLs.append(url.absoluteString)
//                    } else {
//                        print("Error getting download URL for image \(index): \(String(describing: error))")
//                    }
//                    uploadGroup.leave()
//                }
//            }
//        }
//
//        uploadGroup.notify(queue: .main) {
//            var recipeData: [String: Any] = [
//                "idMeal": recipeID,
//                "strMeal": recipe.strMeal,
//                "strCategory": recipe.strCategory,
//                "strArea": recipe.strArea,
//                "strInstructions": recipe.strInstructions,
//                "strYoutube": recipe.strYoutube,
//                "strIngredients": recipe.strIngredients,
//                "strMeasures": recipe.strMeasures,
//                "addedBy": userID,
//                "timestamp": Timestamp(date: Date())
//            ]
//
//            if !uploadedImageURLs.isEmpty {
//                recipeData["images"] = uploadedImageURLs
//            }
//
//            self.db.collection("users").document(userID).collection("recipes").document(recipeID).setData(recipeData) { error in
//                if let error = error {
//                    print("Error saving recipe to Firestore: \(error)")
//                } else {
//                    print("Recipe saved successfully to Firestore.")
//                }
//                completion(error)
//            }
//        }
//    }
    
    
    func saveRecipeWithMedia(recipe: Meal, images: [UIImage], completion: @escaping (Error?) -> Void) {
            guard let userID = Auth.auth().currentUser?.uid else {
                completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
                return
            }

            let recipeID = recipe.idMeal
            var uploadedImageURLs: [String] = []
            let uploadGroup = DispatchGroup()

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
//                            print("Image \(index) uploaded successfully: \(url.absoluteString)")
                            uploadedImageURLs.append(url.absoluteString)
                        } else {
                            print("Error getting download URL for image \(index): \(String(describing: error))")
                        }
                        uploadGroup.leave()
                    }
                }
            }

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
    


    // Fetch Recipes for Logged-in User
//        func fetchSavedRecipes(completion: @escaping ([Meal]?, Error?) -> Void) {
//            guard let user = Auth.auth().currentUser else {
//                    print("User not authenticated.")
//                completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
//                    return
//                }
//                print("User authenticated with ID: \(user.uid)")
//            guard let user = Auth.auth().currentUser else {
//                completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
//                return
//            }
//
//            db.collection("users").document(user.uid).collection("savedRecipes").getDocuments { snapshot, error in
//                if let error = error {
//                    completion(nil, error)
//                    return
//                }
//
//                let recipes = snapshot?.documents.compactMap { document -> Meal? in
//                    let data = document.data()
//                    print("Fetched Recipe Data: \(data)") // Debugging Log
//                    return Meal(
//                        idMeal: data["idMeal"] as? String ?? UUID().uuidString,
//                        strMeal: data["strMeal"] as? String ?? "Unknown",
//                        strCategory: data["strCategory"] as? String ?? "Unknown",
//                        strArea: data["strArea"] as? String ?? "Unknown",
//                        strInstructions: data["strInstructions"] as? String ?? "",
//                        strMealThumb: data["strMealThumb"] as? String ?? "",
//                        strYoutube: data["strYoutube"] as? String ?? "",
//                        strIngredients: data["strIngredients"] as? [String] ?? [],
//                        strMeasures: data["strMeasures"] as? [String] ?? [],
//                        imageUrls: data["images"] as? [String] ?? [] // Fetch images from Firestore
//                    )
//                }
//                print("Recipes Decoded: \(recipes)") // Log decoded recipes
//
//                completion(recipes, nil)
//            }
//        }
    
    func fetchSavedRecipes(completion: @escaping ([Meal]?, Error?) -> Void) {
            guard let user = Auth.auth().currentUser else {
                print("User not authenticated.")
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
//                    print("Fetched Recipe Data: \(data)") // Debugging Log
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
                        imageUrls: data["images"] as? [String] ?? [] // Fetch images from Firestore
                    )
                }
                print("Recipes Decoded: \(recipes ?? [])") // Log decoded recipes

                completion(recipes, nil)
            }
        }

    // Fetch All Public Recipes (Optional)
//    func fetchAllRecipes(completion: @escaping ([Meal]?, Error?) -> Void) {
//        guard let user = Auth.auth().currentUser else {
//                print("User not authenticated.")
//            completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
//                return
//            }
//            print("User authenticated with ID: \(user.uid)")
//        db.collection("recipes").getDocuments { snapshot, error in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//
//            let recipes = snapshot?.documents.compactMap { document -> Meal? in
//                let data = document.data()
//                print("Fetched Recipe Data: \(data)") // Debugging Log
//                return Meal(
//                    idMeal: data["idMeal"] as? String ?? UUID().uuidString,
//                    strMeal: data["strMeal"] as? String ?? "Unknown",
//                    strCategory: data["strCategory"] as? String ?? "Unknown",
//                    strArea: data["strArea"] as? String ?? "Unknown",
//                    strInstructions: data["strInstructions"] as? String ?? "",
//                    strMealThumb: data["strMealThumb"] as? String ?? "",
//                    strTags: data["strTags"] as? String,
//                    strYoutube: data["strYoutube"] as? String ?? "",
//                    strIngredients: data["strIngredients"] as? [String] ?? [],
//                    strMeasures: data["strMeasures"] as? [String] ?? []
//                )
//            }
//            print("Recipes Decoded: \(recipes)") // Log decoded recipes
//
//            completion(recipes, nil)
//        }
//    }
    
    
//    func fetchAllUserRecipes(completion: @escaping ([Meal]) -> Void) {
//        guard let user = Auth.auth().currentUser else {
//                print("User not authenticated.")
//            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]) as! [Meal])
//                return
//            }
//            print("User authenticated with ID: \(user.uid)")
//        db.collectionGroup("recipes").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching all user recipes: \(error)")
//                completion([])
//                return
//            }
//
//            let recipes = snapshot?.documents.compactMap { document -> Meal? in
//                let data = document.data()
//                print("Fetched Recipe Data: \(data)") // Debugging Log
//                return Meal(
//                    idMeal: data["idMeal"] as? String ?? UUID().uuidString,
//                    strMeal: data["strMeal"] as? String ?? "Unknown",
//                    strCategory: data["strCategory"] as? String ?? "Unknown",
//                    strArea: data["strArea"] as? String ?? "Unknown",
//                    strInstructions: data["strInstructions"] as? String ?? "",
//                    strMealThumb: data["strMealThumb"] as? String ?? "",
//                    strIngredients: data["strIngredients"] as? [String] ?? [],
//                    strMeasures: data["strMeasures"] as? [String] ?? [],
//                    imageUrls: data["images"] as? [String] ?? [],
//                    isUserAdded: true
//                )
//            }
//            print("Recipes Decoded: \(recipes)") // Log decoded recipes
//
//            completion(recipes ?? [])
//        }
//    }
    
    // Fetch All User Recipes
//        func fetchAllUserRecipes(completion: @escaping ([Meal]) -> Void) {
//            guard let user = Auth.auth().currentUser else {
//                print("User not authenticated.")
//                completion([])
//                return
//            }
//
//            db.collectionGroup("recipes").getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching all user recipes: \(error)")
//                    completion([])
//                    return
//                }
//                print("Number of documents fetched: \(snapshot!.documents.count)")
//                
//
//                let recipes = snapshot?.documents.compactMap { document -> Meal? in
//                    let data = document.data()
//                    print("Fetched Recipe Data: \(data)") // Debugging Log
//                    return Meal(
//                        idMeal: data["idMeal"] as? String ?? UUID().uuidString,
//                        strMeal: data["strMeal"] as? String ?? "Unknown",
//                        strCategory: data["strCategory"] as? String ?? "Unknown",
//                        strArea: data["strArea"] as? String ?? "Unknown",
//                        strInstructions: data["strInstructions"] as? String ?? "",
//                        strMealThumb: data["strMealThumb"] as? String ?? "",
//                        strIngredients: data["strIngredients"] as? [String] ?? [],
//                        strMeasures: data["strMeasures"] as? [String] ?? [],
//                        imageUrls: data["images"] as? [String] ?? [],
//                        isUserAdded: true
//                    )
//                }
//                print("Recipes Decoded: \(recipes ?? [])") // Log decoded recipes
//
//                completion(recipes ?? [])
//            }
//        }
    
    
    
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
//                print("Fetched Recipe Data: \(data)") // Debugging Log

                // Safeguard against missing fields
                guard let idMeal = data["idMeal"] as? String,
                      let strMeal = data["strMeal"] as? String else {
                    print("Missing required fields in document: \(document.documentID)")
                    return nil
                }

                let strYoutube = data["strYoutube"] as? String ?? "" // Explicitly handle YouTube link

//                print("YouTube Link Fetched: \(strYoutube)") // Debugging Log

                return Meal(
                    idMeal: idMeal,
                    strMeal: strMeal,
                    strCategory: data["strCategory"] as? String ?? "Unknown",
                    strArea: data["strArea"] as? String ?? "Unknown",
                    strInstructions: data["strInstructions"] as? String ?? "",
                    strMealThumb: data["strMealThumb"] as? String ?? "",
                    strYoutube: strYoutube, // Ensure YouTube is set
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




    
//    func deleteMeal(_ meal: Meal, completion: @escaping (Error?) -> Void) {
//        guard let userID = Auth.auth().currentUser?.uid else {
//            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
//            return
//        }
//
//        let recipeRef = db.collection("users").document(userID).collection("recipes").document(meal.idMeal)
//
//        // Remove from Firestore
//        recipeRef.delete { error in
//            completion(error) // Notify the caller of success or failure
//        }
//    }
    func deleteMeal(_ meal: Meal, completion: @escaping (Error?) -> Void) {
            guard let userID = Auth.auth().currentUser?.uid else {
                completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
                return
            }

            let recipeRef = db.collection("users").document(userID).collection("recipes").document(meal.idMeal)
            let storageRef = storage.reference().child("users/\(userID)/recipes/\(meal.idMeal)")

            storageRef.listAll { result, error in
                if let error = error {
                    print("Error listing files in storage: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                let dispatchGroup = DispatchGroup()

                result?.items.forEach { item in
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
                    recipeRef.delete { error in
                        if let error = error {
                            print("Error deleting recipe document: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted recipe and associated images.")
                        }
                        completion(error)
                    }
                }
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
