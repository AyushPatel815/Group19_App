//
//  ProfilePageView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/22/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import FirebaseStorage


struct ProfilePageView: View {
    @Binding var meals: [Meal]
    @Binding var savedMeals: [Meal]
    
    @State private var userRecipes: [Meal] = []
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = "••••••••"
    @State private var confirmPassword: String = "••••••••"
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isEditing: Bool = false
    @State private var isChangingPassword: Bool = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @State private var alertAction: (() -> Void)? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var loadedImages: [String: UIImage] = [:] // Dictionary to cache loaded images by URL
    
    @AppStorage("profileImagePath") private var profileImagePath: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @State private var hasFetchedProfile = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                profileHeader()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        userInformationSection()
                        userRecipesSection()
                    }
                    .padding(.top, 20)
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.top, -60)
                
            }
            .onAppear {
                if !hasFetchedProfile {
                    fetchUserProfile()
                    fetchUserRecipes()
                    hasFetchedProfile = true
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("Yes", role: .destructive) {
                    alertAction?()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .onAppear {
            loadProfileImage() // Load the saved profile image on appear
        }
    }
    
    // MARK: - Profile Header
    @ViewBuilder
    private func profileHeader() -> some View {
        ZStack {
            // Background Shape
            BottomRoundedShape(cornerRadius: 80)
                .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 180)
            
            // Profile Image and Sign Out Button
            HStack {
                // Profile Image
                Button(action: {
                    isImagePickerPresented = true // Open the image picker
                }) {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 170)
                .padding(.top, 45)
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    alertMessage = "Are you sure you want to Log out?"
                    alertAction = { isLoggedIn = false }
                    showAlert = true
                }) {
                    Text("Log out")
                        .font(.subheadline)
                        .bold()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 12)
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.trailing, 20)
                .padding(.top,-10)
            }
        }
        .frame(height: 180)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $profileImage, onSave: saveProfileImage)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Image Loading & Saving
    private func loadProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile image URL: \(error)")
                return
            }
            guard let data = snapshot?.data(), let urlString = data["profileImageURL"] as? String, let url = URL(string: urlString) else { return }
            
            // Download the image from the URL
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.profileImage = image
                    }
                }
            }
        }
    }
    
    private func saveProfileImage(_ image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let storageRef = Storage.storage().reference().child("users/\(userID)/profileImage.png")
        if let imageData = image.pngData() {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting profile image URL: \(error)")
                        return
                    }
                    guard let url = url else { return }
                    saveProfileImagePathToFirestore(for: userID, url: url.absoluteString)
                }
            }
        }
    }
    
    /// Save the image URL in Firestore under the user's document
    private func saveProfileImagePathToFirestore(for userID: String, url: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["profileImageURL": url], merge: true) { error in
            if let error = error {
                print("Error saving profile image URL in Firestore: \(error)")
            } else {
                print("Profile image URL saved successfully.")
            }
        }
    }
    
    
    
    // MARK: - User Information Section
    @ViewBuilder
    private func userInformationSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("User Information")
                    .font(.headline)
                Spacer()
                Button(action: {
                    if isEditing {
                        // Validate user info before saving
                        if validateUserInfo() {
                            alertMessage = "Are you sure you want to save changes to your profile?"
                            alertAction = handleProfileUpdate
                            showAlert = true
                            isEditing = false // Exit edit mode only if validation passes
                        } else {
                            // Validation failed, keep editing mode
                            showAlert = true
                        }
                    } else {
                        isEditing = true // Enter edit mode
                    }
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            AccountDetailField(title: "First Name", value: $firstName, isEditable: isEditing)
            AccountDetailField(title: "Last Name", value: $lastName, isEditable: isEditing)
            AccountDetailField(title: "Email", value: $email, isEditable: isEditing)
            
            if isChangingPassword {
                Divider().padding(.vertical, 10)
                passwordFields()
                HStack {
                    Button(action: {
                        saveNewPassword()
                    }) {
                        Text("Save Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        isChangingPassword = false
                        password = "••••••••"
                        confirmPassword = "••••••••"
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 10)
            } else {
                Divider().padding(.vertical, 10)
                HStack {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        alertMessage = "Are you sure you want to change your password?"
                        alertAction = {
                            DispatchQueue.main.async {
                                isChangingPassword = true
                                password = ""
                                confirmPassword = ""
                            }
                        }
                        showAlert = true
                    }) {
                        Text("Change Password")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                Text(password)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
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
    
    @ViewBuilder
    private func userRecipeRow(for meal: Meal) -> some View {
        NavigationLink(destination: RecipeDetailPageView(meal: meal)) {
            HStack {
                if let urlString = meal.imageUrls?.first ?? (meal.strMealThumb.isEmpty ? nil : meal.strMealThumb),
                   let url = URL(string: urlString) {
                    ZStack {
                        if let image = loadedImages[urlString] {
                            // Display the cached image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .cornerRadius(10)
                        } else {
                            // Show a ProgressView while the image is loading
                            ProgressView()
                                .frame(width: 120, height: 120)
                                .onAppear {
                                    loadImage(from: url, for: urlString)
                                }
                        }
                        
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
                    alertMessage = "Are you sure you want to delete this post?"
                    alertAction = { deleteMeal(meal) }
                    showAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    
    @ViewBuilder
    private func passwordFields() -> some View {
        VStack(spacing:10) {
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                } else {
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Re-type Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                } else {
                    SecureField("Re-type Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                Button(action: {
                    //                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Password Save Logic
    private func saveNewPassword() {
        guard !password.isEmpty else {
            alertMessage = "Password cannot be empty."
            showAlert = true
            return
        }
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long."
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if let error = error {
                alertMessage = "Error updating password, please open app again"
                showAlert = true
            } else {
                alertMessage = "Password updated successfully!"
                isChangingPassword = false // Exit password editing mode
                password = "••••••••"
                confirmPassword = "••••••••"
                isEditing = false // Exit overall editing mode
                showAlert = true
            }
        }
    }
    
    func getYouTubeEmbedURL(youtubeLink: String) -> String {
        // Check if it's a standard YouTube link
        if youtubeLink.contains("youtube.com/watch?v="),
           let videoID = youtubeLink.split(separator: "=").last?.split(separator: "&").first {
            return "https://www.youtube.com/embed/\(videoID)"
        }
        // Check if it's a shortened YouTube link (youtu.be)
        else if youtubeLink.contains("youtu.be"),
                let videoID = youtubeLink.split(separator: "/").last?.split(separator: "?").first {
            return "https://www.youtube.com/embed/\(videoID)"
        }
        // Return the original link if it doesn't match the above formats
        return youtubeLink
    }
    
    
    
    
    // MARK: - Validation Function
    private func validateUserInfo() -> Bool {
        if firstName.count > 20 {
            alertMessage = "First name must be at most 20 characters long."
            return false
        }
        
        if lastName.count > 20 {
            alertMessage = "Last name must be at most 20 characters long."
            return false
        }
        
        if !isValidEmail(email) {
            alertMessage = "Please enter a valid email address containing '@' and '.com'."
            return false
        }
        
        return true // All fields are valid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // MARK: - Profile Update Logic
    private func handleProfileUpdate() {
        if isChangingPassword {
            guard password == confirmPassword else {
                alertMessage = "Passwords do not match!"
                showAlert = true
                return
            }
            saveNewPassword()
        }
        updateUserProfile()
    }
    
    private func updateUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        if email != Auth.auth().currentUser?.email {
            Auth.auth().currentUser?.updateEmail(to: email) { error in
                if let error = error {
                    print("Error updating email: \(error)")
                }
            }
        }
        
        let updatedData: [String: Any] = ["firstName": firstName, "lastName": lastName, "email": email]
        Firestore.firestore().collection("users").document(userID).updateData(updatedData) { error in
            if let error = error {
                print("Error updating user profile: \(error)")
            }
        }
    }
    
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
    
    private func fetchUserRecipes() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirestoreHelper.shared.listenForUserRecipes { recipes in
            DispatchQueue.main.async {
                self.userRecipes = recipes
                print("Fetched user recipes: \(self.userRecipes)")
                
            }
        }
    }
    
    
    private func deleteMeal(_ meal: Meal) {
        FirestoreHelper.shared.deleteMealFromAllLocations(meal) { success in
            if success {
                DispatchQueue.main.async {
                    // Remove from local arrays
                    userRecipes.removeAll { $0.idMeal == meal.idMeal }
                    meals.removeAll { $0.idMeal == meal.idMeal }
                    savedMeals.removeAll { $0.idMeal == meal.idMeal }
                    print("Recipe deleted from all locations and local arrays updated.")
                }
            } else {
                print("Failed to delete recipe from all locations.")
            }
        }
    }
    
    // MARK: - Load Image Function
    private func loadImage(from url: URL, for urlString: String) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        loadedImages[urlString] = uiImage // Cache the loaded image
                    }
                }
            } catch {
                print("Error loading image from \(url.absoluteString): \(error)")
            }
        }
    }
}

struct AccountDetailField: View {
    let title: String
    @Binding var value: String
    var isEditable: Bool = true
    var isSecure: Bool = false
    
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
                Text(value)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
    }
}


// MARK: - Image Picker Component
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onSave: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self = self, let uiImage = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self.parent.image = uiImage
                    self.parent.onSave(uiImage)
                }
            }
        }
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
