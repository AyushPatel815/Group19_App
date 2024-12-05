//
//  ContentView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/19/24.
//


import SwiftUI


struct ContentView: View {
    @State var selectedTab: Tab = .Home   // Tracks the currently selected tab
    @State private var savedMeals: [Meal] = []    // List of saved meals
    @State private var meals: [Meal] = []   // List of all meals
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false   // Persistent login state
    @State private var isSplashScreenActive = true // State to handle splash screen visibility
    @State private var showLoginView = false // Tracks the start of the login transition


    @Namespace var animation   // Namespace for shared animations between views

    var body: some View {
        Group {
            if isSplashScreenActive {
                
                // MARK: - Splash Screen
                ZStack {
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
                            .frame(width: 250, height: 220)
                        
                        // Splash Screen Title
                        if !showLoginView {
                            Text("Welcome to Food Palace!!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .transition(.opacity) // Fade out text
                        }
                        
                        Spacer()
                            .frame(height: 400)
                    }
                    
                
                }
            } else {
                
                // MARK: - Main Content or Login View
                if isLoggedIn {
                    mainContentView
                        .transition(.move(edge: .trailing)) // Add smooth transition to main content
                } else {
                    LoginView()
                        .animation(.easeInOut(duration: 1.0), value: showLoginView)

                }
            }
        }
        .animation(.easeInOut(duration: 1.0), value: isSplashScreenActive)   // Splash screen transition
        .animation(.easeInOut(duration: 0.8), value: showLoginView)   // Login screen transition
        .onAppear {
            // Trigger the first animation (fade out text)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showLoginView = true // Text fades out
                }

                // Trigger the second animation (switch to login view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isSplashScreenActive = false // Splash screen transitions out
                    }
                }
            }
        }

    }
    
    // MARK: - Main Content View (TabView)
    var mainContentView: some View {
        TabView(selection: $selectedTab) {
            
            // Home Tab
            HomePageView(meals: $meals, savedMeals: $savedMeals)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Home)
            
            //Savepage Tab
            SavedPageView(savedMeals: $savedMeals, meals: $meals)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Save)
            
            // Calender page Tab
            CalendarView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Calendar)
            
            // Profile page tab
            ProfilePageView(meals: $meals, savedMeals: $savedMeals)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Profile)
        }
        .overlay(
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    TabButton(tab: tab)
                }
                .padding(.vertical, 7)
                .padding(.bottom, getSafeArea().bottom == 0 ? 5 : (getSafeArea().bottom - 5))
                .background(.yellow)
            },
            alignment: .bottom
        )
        .padding(.bottom)
        .ignoresSafeArea(.all, edges: .bottom)
    }


    // MARK: - Tab Button
    func TabButton(tab: Tab) -> some View {
        GeometryReader { proxy in
            Button(action: {
                withAnimation(.spring()) {
                    selectedTab = tab
                }
            }, label: {
                VStack(spacing: 0) {
                    VStack {
                        if tab == .Calendar {
                            Image(systemName: "calendar")
                                .resizable()
                                .foregroundColor(.black)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .offset(y: selectedTab == tab ? -15 : 0)
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            MaterialEffect(style: .light)
                                                .clipShape(Circle())
                                                .matchedGeometryEffect(id: "Tab", in: animation)
                                            Text("")
                                                .foregroundStyle(.yellow)
                                                .font(.footnote)
                                                .padding(25)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .offset(y: selectedTab == tab ? -15 : 0)
                                )
                        } else {
                            Image(systemName: selectedTab == tab ? tab.iconName + ".fill" : tab.iconName)
                                .resizable()
                                .foregroundColor(.black)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .offset(y: selectedTab == tab ? -15 : 0)
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            MaterialEffect(style: .light)
                                                .clipShape(Circle())
                                                .matchedGeometryEffect(id: "Tab", in: animation)
                                            Text("")
                                                .foregroundStyle(.yellow)
                                                .font(.footnote)
                                                .padding(25)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .offset(y: selectedTab == tab ? -15 : 0)
                                )
                        }
                    }
                    Text(tab.TabName)
                        .foregroundStyle(.black)
                        .font(.footnote)
                        .padding(.top, 5)
                }
            })
        }
        .frame(height: 20)
    }
}


#Preview {
    ContentView()
}

// MARK: - Tab Enum
enum Tab: String, CaseIterable {
    case Home = "house"
    case Save = "suit.heart"
    case Calendar = "calendar"
    case Profile = "person"
    
    var iconName: String {
        // Map each tab to its system icon name
        switch self {
            case .Home: return "house"
            case .Save: return "suit.heart"
            case .Calendar: return "calendar"
            case .Profile: return "person"
        }
    }
    
    var TabName: String {
        // Map each tab to its display name
        switch self {
            case .Home: return "Home"
            case .Save: return "Favorite"
            case .Calendar: return "Calendar"
            case .Profile: return "Profile"
        }
    }
}

// MARK: - Safe Area Helper
extension View {
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as?
                UIWindowScene else { return .zero }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else { return .zero }
        
        return safeArea
    }
}

// MARK: - Material Effect for Tab Highlight
struct MaterialEffect: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
