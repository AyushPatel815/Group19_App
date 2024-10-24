//
//  SignupView.swift
//  Group19_App
//
//  Created by Joshua Hernandez on 10/24/24.
//

import SwiftUI

struct SignupView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var rememberMe: Bool = false

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
            
            VStack(alignment: .leading){
                Text("First Name")
                    .fontWeight(.bold)

                
                
                TextField("", text: $firstName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                        )
            }
            .padding(.horizontal)
            
            
            VStack(alignment: .leading){
                Text("Last Name")
                    .fontWeight(.bold)

                
                
                TextField("", text: $firstName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8) 
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    
                
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading){
                Text("Email")
                    .fontWeight(.bold)
                
                TextField("", text: $firstName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                        )
                
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading){
                Text("Password")
                    .fontWeight(.bold)
                
                TextField("", text: $firstName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                        )
                
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading){
                Text("Confirm Password")
                    .fontWeight(.bold)
                TextField("", text: $firstName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                        )
            }
            .padding(.horizontal)
            // Remember me toggle
            Toggle(isOn: $rememberMe) {
                Text("Remember me")
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Signup Button
            Button(action: {
                // Handle signup action
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width:200)
                    .padding()
                    .background(Color(red: 220 / 255, green: 168 / 255, blue: 34 / 255))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
            
            
            Spacer()
            
//            Rectangle()
//                .fill(Color(red: 220 / 255, green: 168 / 255, blue: 34 / 255)) // DCA822 RGB color
//                .frame(height: 30) // Adjust the height as needed
//                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}


#Preview {
    SignupView()
}
