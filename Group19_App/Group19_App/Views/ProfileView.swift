// ProfileView.swift
// Group19_App

import SwiftUI

struct BottomRoundedShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        // Bottom right corner with corner radius
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))

        // Bottom left corner with corner radius
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))

        // Back to top left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack { // Wrap in NavigationStack
            VStack {
                ZStack {
                    // Custom shape with only bottom corners rounded
                    BottomRoundedShape(cornerRadius: 80)  // Adjust corner radius here
                        .fill(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 210)

                    VStack {
                        HStack {
                            Spacer()
                            
                            // NavigationLink to the SettingsView
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill") // Settings icon
                                    .font(.system(size: 25))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 30)
                                    .padding(.top, 40)
                            }

                        }
                        
                        // Profile Image
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .padding(.top, 0)  // Adjust padding to match design
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .padding(.bottom, 0)
                .frame(height: 160)
                
                VStack {
                    HStack(spacing: 190) {
                        VStack {
                            Text("Followers")
                                .font(.custom("Avenir Next", size: 15))
                                .background(Color.gray.opacity(0.5))
                                .fontWeight(.bold)
                            
                            Text("500")
                                .font(.custom("Avenir Next", size: 15))
                        }
                        
                        VStack {
                            Text("Views")
                                .font(.custom("Avenir Next", size: 15))
                                .background(Color.gray.opacity(0.5))
                                .fontWeight(.bold)
                                        
                            Text("2000")
                                .font(.custom("Avenir Next", size: 15))
                        }
                    }
                    .padding(.bottom, 40)
                    
                    HStack {
                        Text("Your Channel")
                            .font(.custom("Avenir Next", size: 25))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.black)
                    
                    // ScrollView will be for Entries that user has posted
                    ScrollView { }
                    .padding(.bottom, 40)
                }

                Spacer()
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Title at the top
            Text("Settings")
                .font(.system(size: 36, weight: .bold)) 
                .padding(.top, 40)
                .padding(.bottom, 20)
            

            VStack(spacing: 10) {
                // Profile Button
                SettingButton(title: "Profile")
                // Dark Theme Button
                SettingButton(title: "Dark Theme")
                // Change Password Button
                SettingButton(title: "Change Password")
                // Update Email Button
                SettingButton(title: "Update Email")
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }

    }
}

struct SettingButton: View {
    let title: String
    
    var body: some View {
        Button(action: {
            print("\(title) tapped")
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.vertical, 16)
                Spacer()
            }
            .padding(.horizontal)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
        }
    }
}

#Preview {
    ProfileView()
}
