//
//  SignupView.swift
//  Group19_App
//
//  Created by Joshua Hernandez on 10/24/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var rememberMe: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @EnvironmentObject var authState: AuthState  // To track login state and navigate to the homepage
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some View {
        VStack {
            // Logo or image at the top
            Image("appLogo")
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.bottom, 10)

            Text("Get Started!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            // First Name Field
            VStack(alignment: .leading) {
                Text("First Name")
                    .fontWeight(.bold)

                TextField("Enter your first name", text: $firstName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .padding(.horizontal)

            // Last Name Field
            VStack(alignment: .leading) {
                Text("Last Name")
                    .fontWeight(.bold)

                TextField("Enter your last name", text: $lastName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .padding(.horizontal)

            // Email Field
            VStack(alignment: .leading) {
                Text("Email")
                    .fontWeight(.bold)

                TextField("Enter your email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .padding(.horizontal)

            // Password Field with Visibility Toggle
            VStack(alignment: .leading) {
                Text("Password")
                    .fontWeight(.bold)

                HStack {
                    if isPasswordVisible {
                        TextField("Enter your password", text: $password)
                    } else {
                        SecureField("Enter your password", text: $password)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .padding(.horizontal)

            // Confirm Password Field with Visibility Toggle
            VStack(alignment: .leading) {
                Text("Confirm Password")
                    .fontWeight(.bold)

                HStack {
                    if isConfirmPasswordVisible {
                        TextField("Confirm your password", text: $confirmPassword)
                    } else {
                        SecureField("Confirm your password", text: $confirmPassword)
                    }
                    Button(action: {
                        isConfirmPasswordVisible.toggle()
                    }) {
                        Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .padding(.horizontal)


            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.bottom, 10)
            }

            // Signup Button
            Button(action: {
//                handleSignup()
                validateAndSignup()

            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(.white)
                } else {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color(red: 220 / 255, green: 168 / 255, blue: 34 / 255))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
            }

            Spacer()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    
    // MARK: - Validation and Signup
        private func validateAndSignup() {
            guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please fill in all fields."
                return
            }

            guard firstName.count <= 20 else {
                errorMessage = "First name must be at most 20 characters."
                return
            }

            guard lastName.count <= 20 else {
                errorMessage = "Last name must be at most 20 characters."
                return
            }

            guard isValidEmail(email) else {
                errorMessage = "Please enter a valid email address."
                return
            }

            guard password.count >= 6 else {
                errorMessage = "Password must be at least 6 characters long."
                return
            }

            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return
            }

            handleSignup()
        }
    
    private func isValidEmail(_ email: String) -> Bool {
           let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
       }

    // MARK: - Handle Signup
    private func handleSignup() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        errorMessage = nil

        // Firebase Auth - Create User
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = "Signup failed: \(error.localizedDescription)"
                return
            }

            guard let userID = authResult?.user.uid else {
                errorMessage = "Unexpected error. Please try again."
                return
            }

            // Add User to Firestore and Navigate to Homepage
            addUserToFirestore(userID: userID)
        }
    }

    // MARK: - Add User to Firestore
    private func addUserToFirestore(userID: String) {
        let userData: [String: Any] = [
            "email": email,
            "firstName": firstName,
            "lastName": lastName
        ]

        Firestore.firestore().collection("users").document(userID).setData(userData) { error in
            if let error = error {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
            } else {
                // Navigate to the homepage on success
//                authState.isAuthenticated = true
                isLoggedIn = true
            }
        }
    }
}


class AuthState: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
        }
    }
}


#Preview {
    SignupView().environmentObject(AuthState())
}
