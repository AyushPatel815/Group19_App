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


    init() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UITabBar.appearance().isHidden = true
    }
    
    @Namespace var animation
    
    var body: some View {
//        Text("Is Logged In: \(isLoggedIn.description)")

        if isLoggedIn {

            mainContentView
        } else {
            LoginView()
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
            AddRecipePageView(meals: $meals)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(Tab.Add)
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
    case Save = "bookmark"
    case Calendar = "calendar"
    case Add = "plus.circle"
    case Profile = "person"
    
    var iconName: String {
        switch self {
            case .Home: return "house"
            case .Save: return "bookmark"
            case .Calendar: return "calendar"
            case .Add: return "plus.circle"
            case .Profile: return "person"
        }
    }
    
    var TabName: String {
        switch self {
            case .Home: return "Home"
            case .Save: return "Save"
            case .Calendar: return "Calendar"
            case .Add: return "Add"
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
