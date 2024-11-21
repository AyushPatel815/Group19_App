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
    static let shared = FirebaseAuthHelper()
    private let db = Firestore.firestore()

    // Register User
    func registerUser(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }
            
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

    // Login User
    func loginUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
}

