//
//  SplashScreenView.swift
//  Group19_App
//
//  Created by Ayush Patel on 12/3/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.orange, .yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Extend the gradient to cover the entire screen
            
            VStack {
                Spacer()
                
                // App Logo
                Image("appLogo")
                    .resizable()
                    .scaledToFit() // Ensures the logo maintains its aspect ratio
                    .frame(width: 300, height: 300) // Adjust the size as needed
                    .padding(.bottom, 20)
                
                // App Title
                Text("Welcome to Food Palace!!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black) // Ensure good contrast
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40) // Adds spacing for longer text
                
                Spacer()
                    .frame(height: 500)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

