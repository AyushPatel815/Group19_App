//
//  ProfilePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//

import SwiftUI

struct ProfilePageView: View {
    @Binding var meals: [Meal]  // Binding to the meals added by the user
    @Binding var savedMeals: [Meal]  // Binding to the saved meals list
    
    // State variables for user details
    @State private var firstName: String = "John"
    @State private var lastName: String = "Doe"
    @State private var email: String = "john.doe@example.com"
    @State private var password: String = "******"
    
    // State variables for edit mode
    @State private var isEditing: Bool = false
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Profile header section
                ZStack {
                    BottomRoundedShape(cornerRadius: 80)
                        .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 180)  // Adjust height for the profile header

                    VStack {
                        // Profile Image
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .padding(.top, 50)  // Keep the padding only for the profile image alignment
                    }
                }
                .ignoresSafeArea(edges: .top)  // This ensures the yellow background goes to the top without space

                // Scrollable content starts right after the header
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // User Information Section
                        VStack(alignment: .leading) {
                            HStack {
                                Text("User Information")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    isEditing.toggle()  // Toggle edit mode
                                }) {
                                    Text(isEditing ? "Done" : "Edit")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            AccountDetailField(title: "First Name", value: $firstName, isEditable: isEditing)
                            AccountDetailField(title: "Last Name", value: $lastName, isEditable: isEditing)
                            AccountDetailField(title: "Email", value: $email, isEditable: isEditing)
                            AccountDetailField(title: "Password", value: $password, isSecure: true, isEditable: isEditing)
                        }
                        .padding(.horizontal)
                        
                        // User-added meals section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Your Channel")
                                    .font(.custom("Avenir Next", size: 25))
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Scrollable section for user-added posts
                            ScrollView {
                                VStack(spacing: 10) {
                                    let userAddedMeals = meals.filter { $0.isUserAdded }
                                    
                                    if userAddedMeals.isEmpty {
                                        Text("No Posts yet!")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                            .padding(.top)
                                    } else {
                                        ForEach(userAddedMeals, id: \.idMeal) { meal in
                                            HStack {
                                                if let imageData = meal.imagesData?.first, let uiImage = UIImage(data: imageData) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 100)
                                                        .cornerRadius(10)
                                                } else if let imageUrl = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
                                                    AsyncImage(url: imageUrl) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 100, height: 100)
                                                            .cornerRadius(10)
                                                    } placeholder: {
                                                        ProgressView()
                                                            .frame(width: 100, height: 100)
                                                    }
                                                } else {
                                                    // Placeholder if no image is available
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 100, height: 100)
                                                        .cornerRadius(10)
                                                        .overlay(Text("No Image").foregroundColor(.gray))
                                                }
                                                
                                                // Meal name and delete button
                                                VStack(alignment: .leading) {
                                                    Text(meal.strMeal)
                                                        .font(.headline)
                                                        .foregroundColor(.black)
                                                    Text(meal.strCategory)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                
                                                // Delete button
                                                Button(action: {
                                                    deleteMeal(meal)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .resizable()
                                                        .foregroundColor(.red)
                                                        .frame(width: 20, height: 20)
                                                        .padding()
                                                }
                                            }
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Sign-out button
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .alert("Are you sure you want to sign out?", isPresented: $showAlert) {
                            Button("Yes", role: .destructive) {
                                // Sign out logic goes here
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        .padding(.bottom,75)
                    }
                    .padding(.top, 20)
                }.padding(.bottom,75)
                    .padding(.top,-60)
            }
        }
    }
    
    // Function to delete a meal from both meals and savedMeals
    func deleteMeal(_ meal: Meal) {
        // Remove the meal from the meals list
        if let index = meals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
            meals.remove(at: index)
        }
        
        // Remove the meal from the saved meals list
        if let savedIndex = savedMeals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
            savedMeals.remove(at: savedIndex)
        }
        
        // Persist changes after deletion
        MealService().saveMeals(meals)
        MealService().saveMeals(savedMeals)
    }
}

// Helper view to create account details fields
struct AccountDetailField: View {
    let title: String
    @Binding var value: String
    var isSecure: Bool = false
    var isEditable: Bool = true  // Determines if the field is editable

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            if isEditable {
                if isSecure {
                    SecureField("Enter \(title)", text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextField("Enter \(title)", text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                if isSecure {
                    Text(value)
                        .font(.body)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Text(value)
                        .font(.body)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct BottomRoundedShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Draw a line to the top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        // Draw a line to the bottom right corner with the rounded corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))

        // Draw a line to the bottom left corner with the rounded corner
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))

        // Finish back at the top left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

#Preview {
    ProfilePageView(meals: .constant([]), savedMeals: .constant([]))  // You can bind meals here in preview
}
