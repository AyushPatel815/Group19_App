//
//  ContentView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/19/24.
//


import SwiftUI


struct ContentView: View {
    @State var selectedTab: Tab = .Home
    @State private var savedMeals: [Meal] = []
    @State private var meals: [Meal] = []
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var isSplashScreenActive = true // State to handle splash screen visibility
    @State private var showLoginView = false // Tracks the start of the login transition



    @Namespace var animation

    var body: some View {
        Group {
            if isSplashScreenActive {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .yellow]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea() // Extend the gradient to cover the entire screen
                    VStack {
                        Spacer()
                        // Logo
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
                if isLoggedIn {
                    mainContentView
                        .transition(.move(edge: .trailing)) // Add smooth transition to main content
                } else {
                    LoginView()
//                        .transition(.move(edge: .trailing)) // Slide LoginView from the right
                        .animation(.easeInOut(duration: 1.0), value: showLoginView)

                }
            }
        }
        .animation(.easeInOut(duration: 1.0), value: isSplashScreenActive)
        .animation(.easeInOut(duration: 0.8), value: showLoginView)
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
    
    var mainContentView: some View {
        TabView(selection: $selectedTab) {
            HomePageView(meals: $meals, savedMeals: $savedMeals)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Home)
            SavedPageView(savedMeals: $savedMeals, meals: $meals)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Save)
            CalendarView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Calendar)
//            AddRecipePageView(meals: $meals)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .tag(Tab.Add)
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

enum Tab: String, CaseIterable {
    case Home = "house"
    case Save = "suit.heart"
    case Calendar = "calendar"
//    case Add = "plus.circle"
    case Profile = "person"
    
    var iconName: String {
        switch self {
            case .Home: return "house"
            case .Save: return "suit.heart"
            case .Calendar: return "calendar"
//            case .Add: return "plus.circle"
            case .Profile: return "person"
        }
    }
    
    var TabName: String {
        switch self {
            case .Home: return "Home"
            case .Save: return "Favorite"
            case .Calendar: return "Calendar"
//            case .Add: return "Add"
            case .Profile: return "Profile"
        }
    }
}


extension View {
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as?
                UIWindowScene else { return .zero }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else { return .zero }
        
        return safeArea
    }
}

struct MaterialEffect: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
