//
//  CalendarView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()  // Current selected date
    @State private var mealPlans: [Date: MealPlan] = [:]  // Dictionary to hold meal plans for each date
    
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)  // 7 columns for the days of the week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Current Month and Year
                    Text(currentMonthAndYear)
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    // Calendar Grid for the Days
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.title3)
                                .bold()
                        }
                        
                        ForEach(daysInMonth(), id: \.self) { date in
                            DayCellView(
                                date: date,
                                hasMealPlan: mealPlans[date] != nil,
                                isSelected: calendar.isDate(date, inSameDayAs: currentDate)  // Check if this is the selected date
                            )
                            .onTapGesture {
                                currentDate = date  // Update the selected date when tapped
                            }
                        }
                    }
                    .padding()
                    
                    // Display the Meal Plan sections for Breakfast, Lunch, and Dinner
                    if let mealPlan = mealPlans[currentDate] {
                        ScrollView {
                            // Display Breakfast Section
                            MealSectionView(
                                mealType: "Breakfast",
                                notes: Binding(
                                    get: { mealPlan.breakfast },
                                    set: { mealPlans[currentDate]?.breakfast = $0 }
                                )
                            )
                            
                            // Display Lunch Section
                            MealSectionView(
                                mealType: "Lunch",
                                notes: Binding(
                                    get: { mealPlan.lunch },
                                    set: { mealPlans[currentDate]?.lunch = $0 }
                                )
                            )
                            
                            // Display Dinner Section
                            MealSectionView(
                                mealType: "Dinner",
                                notes: Binding(
                                    get: { mealPlan.dinner },
                                    set: { mealPlans[currentDate]?.dinner = $0 }
                                )
                            )
                        }
                        .padding(.top)
                        .padding(.bottom,45)
                    } else {
                        Text("No meals planned for \(formattedDate(currentDate))")
                            .font(.title2)
                            .padding(.top)
                        
                        // Initialize the meal plan when needed
                        Button(action: {
                            mealPlans[currentDate] = MealPlan()  // Initialize meal plan for the selected date
                        }) {
                            Text("Create Meal Plan")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("Meal Planner")
            }
        }
    }
    
    // Function to return the full name of the current month and year
    var currentMonthAndYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    // Function to return the list of days in the current month
    func daysInMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: Date()) else { return [] }
        
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        
        return range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    // Helper function to return the formatted string for a date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Days of the week (short symbols like "Sun", "Mon", etc.)
    var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols
    }
}

// MealPlan struct that holds breakfast, lunch, and dinner
struct MealPlan {
    var breakfast: [String] = []
    var lunch: [String] = []
    var dinner: [String] = []
}

#Preview {
    CalendarView()
}
