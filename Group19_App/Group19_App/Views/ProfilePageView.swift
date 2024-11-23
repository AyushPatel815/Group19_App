//
//  ProfilePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//

//import SwiftUI
//
//struct ProfilePageView: View {
//    @Binding var meals: [Meal]  // Binding to the meals added by the user
//    @Binding var savedMeals: [Meal]  // Binding to the saved meals list
//    
//    @State private var firstName: String = "John"
//    @State private var lastName: String = "Doe"
//    @State private var email: String = "john.doe@example.com"
//    @State private var password: String = "******"
//    
//    @State private var isEditing: Bool = false
//    @State private var showAlert = false
//    
//    // Track login state
//    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Static Profile header section
//                ZStack {
//                    BottomRoundedShape(cornerRadius: 80)
//                        .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
//                        .frame(height: 180)  // Adjust height for the profile header
//
//                    VStack {
//                        // Profile Image
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: 100, height: 100)
//                            .foregroundColor(.white)
//                            .padding(.top, 50)  // Keep the padding only for the profile image alignment
//                    }
//                }
//                .ignoresSafeArea(edges: .top)
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 30) {
//                        // User Information Section
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text("User Information")
//                                    .font(.headline)
//                                Spacer()
//                                Button(action: {
//                                    isEditing.toggle()
//                                }) {
//                                    Text(isEditing ? "Done" : "Edit")
//                                        .font(.subheadline)
//                                        .foregroundColor(.blue)
//                                }
//                            }
//                            AccountDetailField(title: "First Name", value: $firstName, isEditable: isEditing)
//                            AccountDetailField(title: "Last Name", value: $lastName, isEditable: isEditing)
//                            AccountDetailField(title: "Email", value: $email, isEditable: isEditing)
//                            AccountDetailField(title: "Password", value: $password, isSecure: true, isEditable: isEditing)
//                        }
//                        .padding(.horizontal)
//                        
//                        // User-added meals section
//                        VStack(alignment: .leading, spacing: 10) {
//                            HStack {
//                                Text("Your Channel")
//                                    .font(.custom("Avenir Next", size: 25))
//                                    .fontWeight(.bold)
//                                Spacer()
//                            }
//                            
//                            Divider()
//                            
//                            // Scrollable section for user-added posts
//                            ScrollView {
//                                VStack(spacing: 10) {
//                                    let userAddedMeals = meals.filter { $0.isUserAdded }
//                                    
//                                    if userAddedMeals.isEmpty {
//                                        Text("No Posts yet!")
//                                            .font(.title2)
//                                            .foregroundColor(.gray)
//                                            .padding(.top)
//                                    } else {
//                                        ForEach(userAddedMeals, id: \.idMeal) { meal in
//                                            HStack {
//                                                if let imageData = meal.imagesData?.first, let uiImage = UIImage(data: imageData) {
//                                                    Image(uiImage: uiImage)
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .frame(width: 100, height: 100)
//                                                        .cornerRadius(10)
//                                                } else if let imageUrl = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
//                                                    AsyncImage(url: imageUrl) { image in
//                                                        image
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .frame(width: 100, height: 100)
//                                                            .cornerRadius(10)
//                                                    } placeholder: {
//                                                        ProgressView()
//                                                            .frame(width: 100, height: 100)
//                                                    }
//                                                } else {
//                                                    Rectangle()
//                                                        .fill(Color.gray.opacity(0.3))
//                                                        .frame(width: 100, height: 100)
//                                                        .cornerRadius(10)
//                                                        .overlay(Text("No Image").foregroundColor(.gray))
//                                                }
//                                                
//                                                VStack(alignment: .leading) {
//                                                    Text(meal.strMeal)
//                                                        .font(.headline)
//                                                        .foregroundColor(.black)
//                                                    Text(meal.strCategory)
//                                                        .font(.subheadline)
//                                                        .foregroundColor(.gray)
//                                                }
//                                                Spacer()
//                                                
//                                                Button(action: {
//                                                    deleteMeal(meal)
//                                                }) {
//                                                    Image(systemName: "trash")
//                                                        .resizable()
//                                                        .foregroundColor(.red)
//                                                        .frame(width: 20, height: 20)
//                                                        .padding()
//                                                }
//                                            }
//                                            .padding()
//                                            .background(Color.gray.opacity(0.1))
//                                            .cornerRadius(10)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                        
//                        // Sign-out button
//                        Button(action: {
//                            showAlert = true
//                        }) {
//                            Text("Sign Out")
//                                .font(.headline)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.red)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        .padding(.horizontal)
//                        .alert("Are you sure you want to sign out?", isPresented: $showAlert) {
//                            Button("Yes", role: .destructive) {
//                                // Set isLoggedIn to false and return to LoginView
//                                isLoggedIn = false
//                            }
//                            Button("Cancel", role: .cancel) {}
//                        }
//                        .padding(.bottom, 75)
//                    }
//                    .padding(.top, 20)
//                }
//                .padding(.bottom, 50)
//                .padding(.top, -60)
//            }
//        }
//        
//    }
//    
//    func deleteMeal(_ meal: Meal) {
//        if let index = meals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
//            meals.remove(at: index)
//        }
//        
//        if let savedIndex = savedMeals.firstIndex(where: { $0.idMeal == meal.idMeal }) {
//            savedMeals.remove(at: savedIndex)
//        }
//        
//        MealService().saveMeals(meals)
//        MealService().saveMeals(savedMeals)
//    }
//}
//
//
//// Helper view to create account details fields
//struct AccountDetailField: View {
//    let title: String
//    @Binding var value: String
//    var isSecure: Bool = false
//    var isEditable: Bool = true  // Determines if the field is editable
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.gray)
//            if isEditable {
//                if isSecure {
//                    SecureField("Enter \(title)", text: $value)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                } else {
//                    TextField("Enter \(title)", text: $value)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//            } else {
//                if isSecure {
//                    Text(value)
//                        .font(.body)
//                        .padding(10)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                } else {
//                    Text(value)
//                        .font(.body)
//                        .padding(10)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//struct BottomRoundedShape: Shape {
//    var cornerRadius: CGFloat
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        // Start at the top left corner
//        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
//
//        // Draw a line to the top right corner
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//
//        // Draw a line to the bottom right corner with the rounded corner
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
//        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
//
//        // Draw a line to the bottom left corner with the rounded corner
//        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
//        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))
//
//        // Finish back at the top left
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//
//        return path
//    }
//}
//
//#Preview {
//    ProfilePageView(meals: .constant([]), savedMeals: .constant([]))  // You can bind meals here in preview
//}




import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfilePageView: View {
    @Binding var meals: [Meal]  // Binding to all meals
    @Binding var savedMeals: [Meal]  // Binding to the saved meals list
    
    @State private var userRecipes: [Meal] = []  // Recipes added by the user
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isEditing: Bool = false
    @State private var showAlert = false
    
    // Track login state
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @State private var isLoading = true
    @State private var hasFetchedProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Profile header section
                profileHeader()

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        userInformationSection()
                        userRecipesSection()
                        signOutButton()
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 50)
                .padding(.top, -60)
            }
            .onAppear {
                if !hasFetchedProfile {
                    fetchUserProfile()
                    fetchUserRecipes()
                    hasFetchedProfile = true
                }
            }
        }
    }
    
    // MARK: - Profile Header
    @ViewBuilder
    private func profileHeader() -> some View {
        ZStack {
            BottomRoundedShape(cornerRadius: 80)
                .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 180)

            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 50)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - User Information Section
    @ViewBuilder
    private func userInformationSection() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("User Information")
                    .font(.headline)
                Spacer()
                Button(action: {
                    if isEditing {
                        updateUserProfile()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            AccountDetailField(title: "First Name", value: $firstName, isEditable: isEditing)
            AccountDetailField(title: "Last Name", value: $lastName, isEditable: isEditing)
            AccountDetailField(title: "Email", value: $email, isEditable: false)
        }
        .padding(.horizontal)
    }

    // MARK: - User Recipes Section
    @ViewBuilder
    private func userRecipesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your Channel")
                    .font(.custom("Avenir Next", size: 25))
                    .fontWeight(.bold)
                Spacer()
            }
            Divider()
            
            if userRecipes.isEmpty {
                Text("No Posts yet!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.top)
            } else {
                ForEach(userRecipes, id: \.idMeal) { meal in
                    userRecipeRow(for: meal)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - User Recipe Row
    @ViewBuilder
    private func userRecipeRow(for meal: Meal) -> some View {
        HStack {
            // Display meal image
            if let imageUrl = meal.imageUrls?.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
            } else if let url = URL(string: meal.strMealThumb), !meal.strMealThumb.isEmpty {
                AsyncImage(url: url) { image in
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
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .overlay(Text("No Image").foregroundColor(.gray))
            }
            
            VStack(alignment: .leading) {
                Text(meal.strMeal)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(meal.strCategory)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                deleteMeal(meal)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Sign Out Button
    @ViewBuilder
    private func signOutButton() -> some View {
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
                isLoggedIn = false
            }
            Button("Cancel", role: .cancel) {}
        }
        .padding(.bottom, 75)
    }

    // MARK: - Delete Meal
    func deleteMeal(_ meal: Meal) {
        FirestoreHelper.shared.deleteMeal(meal) { error in
            if let error = error {
                print("Failed to delete recipe: \(error)")
            } else {
                DispatchQueue.main.async {
                    meals.removeAll { $0.idMeal == meal.idMeal }
                    savedMeals.removeAll { $0.idMeal == meal.idMeal }
                }
            }
        }
    }

    // MARK: - Fetch User Profile
    private func fetchUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error)")
                return
            }
            guard let data = snapshot?.data() else { return }
            firstName = data["firstName"] as? String ?? ""
            lastName = data["lastName"] as? String ?? ""
            email = data["email"] as? String ?? Auth.auth().currentUser?.email ?? ""
        }
    }

    // MARK: - Update User Profile
    private func updateUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let updatedData: [String: Any] = ["firstName": firstName, "lastName": lastName, "email": email]
        Firestore.firestore().collection("users").document(userID).updateData(updatedData) { error in
            if let error = error {
                print("Error updating user profile: \(error)")
            }
        }
    }

    // MARK: - Fetch User Recipes
    private func fetchUserRecipes() {
        FirestoreHelper.shared.listenForUserRecipes { newRecipes in
            DispatchQueue.main.async {
                userRecipes = newRecipes
            }
        }
    }
}

struct AccountDetailField: View {
    let title: String
    @Binding var value: String
    var isEditable: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            if isEditable {
                TextField("Enter \(title)", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(value)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
    }
}

struct BottomRoundedShape: Shape {
    var cornerRadius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.width - cornerRadius, y: rect.height), control: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - cornerRadius), control: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ProfilePageView(meals: .constant([]), savedMeals: .constant([]))
}
