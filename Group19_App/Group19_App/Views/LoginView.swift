

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""  // email string
    @State private var password: String = ""  // password string
    @State private var isPasswordVisible: Bool = false // Toggle for password visibility
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var isForgotPasswordPresented: Bool = false // To present Forgot Password dialog

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // Logo or image at the top
                Image("appLogo")
                    .resizable()
                    .frame(width: 150, height: 120)
                Spacer()


                // Email input
                VStack(alignment: .leading) {
                    Text("Email")
                        .fontWeight(.bold)
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)


                // Password input with eye icon
                VStack(alignment: .leading) {
                    Text("Password")
                        .fontWeight(.bold)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                                .padding()
                                .background(Color.white)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(Color.white)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle() // Toggle visibility
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                
                        }
                        .padding(.trailing, 10)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .background(.white)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                // Forgot password link
                HStack {
                    Button(action: {
                        isForgotPasswordPresented = true // Show Forgot Password dialog
                    }) {
                        Text("Forgot Password?")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.black)
                            .padding(.leading, 25)
                            .underline()
                    }
                    Spacer()
                }

                // Login Button
                Button(action: {
                    validateAndAuthenticateUser()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                    } else {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.top, 20)
                    }
                }

                // Error message display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 10)
                }

                // Sign-up link
                HStack {
                    Text("New to Food Palace?")
                    NavigationLink(destination: SignupView()) {
                        Text("Sign up!!")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 20)

                Spacer()
                    .frame(height: 250)
            }
            .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .ignoresSafeArea(.all, edges: .top)
            .alert("Forgot Password", isPresented: $isForgotPasswordPresented, actions: {
                TextField("Enter your email", text: $email)
                    .autocapitalization(.none)
                Button("Send Reset Email", action: {
                    sendPasswordReset()
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Enter your email to receive a password reset link.")
            })
        }
    }

    // MARK: - Firebase Authentication
    func authenticateUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }

            // If login is successful, set isLoggedIn to true
            isLoggedIn = true
        }
    }

    // MARK: - Forgot Password
    func sendPasswordReset() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email to reset your password."
            return
        }
        
        guard email.count >= 6 else {
            errorMessage = "Email must be at least 6 characters long."
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }

        // Check if the email exists in Firebase Authentication
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                errorMessage = "Failed to verify email: \(error.localizedDescription)"
                return
            }

            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                // Email exists in Firebase, proceed with password reset
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        errorMessage = "Failed to send reset email: \(error.localizedDescription)"
                    } else {
                        errorMessage = "A password reset email has been sent to \(email)."
                    }
                }
            } else {
                // Email does not exist
                errorMessage = "Email not found. Please sign up first."
            }
        }
    }

    
    // MARK: - Validation and Authentication
        func validateAndAuthenticateUser() {
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter email and password."
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

            authenticateUser()
        }
    
    func isValidEmail(_ email: String) -> Bool {
            // Basic regex for email validation
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        }
}



#Preview {
    LoginView()
}
