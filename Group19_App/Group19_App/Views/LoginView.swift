//import SwiftUI

//import UIKit
import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // Logo or image at the top
                Image("appLogo")
                    .resizable()
                    .frame(width: 250, height: 200)

                Text("Welcome to Food Palace!!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                // Username input
                VStack(alignment: .leading) {
                    Text("Username")
                        .fontWeight(.bold)
                    TextField("Enter your username", text: $username)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .frame(width: 350)
                }
                .padding(.horizontal)

                // Password input
                VStack(alignment: .leading) {
                    Text("Password")
                        .fontWeight(.bold)
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .frame(width: 350)
                }
                .padding(.horizontal)

                // Forgot password link
                HStack {
                    Button(action: {
                        // Handle forgot password action
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.black)
                            .padding(.leading, 35)
                            .underline()
                    }
                    Spacer()
                }

                // Login Button
                Button(action: {
                    authenticateUser()  // Handle the login
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }

                // Sign-up link
                HStack {
                    Text("New to Food Palace?")
                    
                    // Use NavigationLink inside the Button
                    NavigationLink(destination: SignupView()) {
                        Text("Sign up!!")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 20)

                Spacer()
            }
            .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .ignoresSafeArea(.all, edges: .top)
        }
    }

    // Authentication function
    func authenticateUser() {
        // Replace with actual authentication logic
        if username == "User" && password == "password" {
            // If authentication is successful, set isLoggedIn to true
            isLoggedIn = true
        } else {
            // Handle incorrect login
            print("Invalid username or password")
        }
    }
}

#Preview {
    LoginView()
}
