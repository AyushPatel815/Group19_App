//
//  Group19_AppApp.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/19/24.
//

import SwiftUI
import FirebaseCore

// MARK: - AppDelegate
/// Handles Firebase initialization during the app's launch.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Called when the application finishes launching.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary indicating why the app was launched (e.g., a push notification).
    /// - Returns: A boolean indicating whether the app finished launching successfully.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()   // Initialize Firebase
        
        return true
    }
}


// MARK: - Group19_AppApp
/// The main entry point of the app.
@main
struct Group19_AppApp: App {
    
    // register app delegate for Firebase setup
    
    // MARK: - Properties
    /// Registers `AppDelegate` for Firebase setup.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// Observes authentication state across the app.
    @StateObject private var authState = AuthState() // Initialize AuthState
    
    // MARK: - Body
    /// Defines the app's main UI scene
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authState)   // Pass `authState` to all child views
        }
    }
}
