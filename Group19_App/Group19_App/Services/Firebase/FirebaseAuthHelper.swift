//
//  FirebaseAuthHelper.swift
//  Group19_App
//
//  Created by Ayush Patel on 11/20/24.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth


class FirebaseAuthHelper {
    static let shared = FirebaseAuthHelper()  // Singleton instance for global access
    private let db = Firestore.firestore()  // Firestore reference
    
    // MARK: - Register User
    func registerUser(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            // Check if an error occurred during account creation
            if let error = error {
                completion(error)
                return
            }
            
            // If the user was created successfully, store their data in Firestore
            if let user = authResult?.user {
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName
                ]
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Login User
    func loginUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            // Pass the result (success or error) back to the caller
            completion(error)
        }
    }
}

