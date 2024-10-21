//
//  CalendarView.swift
//  Group19_App
//
//  Created by Ayush Patel on 10/20/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()  // Current selected date
    @State private var mealPlans: [Date: [String]] = [:]  // Dictionary to hold meal plans for each date

    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)  // 7 columns for the days of the week

    var body: some View {
        NavigationStack {
            VStack {
                // Current Month and Year
                Text("\(currentMonthAndYear)")
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
                        DayCellView(date: date, hasMealPlan: mealPlans[date] != nil)
                            .onTapGesture {
                                currentDate = date
                            }
                    }
                }
                .padding()

                // Display the Meal Plan or option to create one for the selected date
                if let meals = mealPlans[currentDate] {
                    Text("Meals for \(formattedDate(currentDate)):")
                        .font(.title2)
                        .padding(.top)

                    List(meals, id: \.self) { meal in
                        Text(meal)
                    }
                } else {
                    Text("No meals planned for \(formattedDate(currentDate))")
                        .font(.title2)
                        .padding(.top)

                    Button(action: {
                        addMealPlan(for: currentDate)
                    }) {
                        Text("Add Meal Plan")
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

    // Function to add a sample meal plan for a date
    func addMealPlan(for date: Date) {
        mealPlans[date] = ["Breakfast: Pancakes", "Lunch: Sandwich", "Dinner: Pasta"]
    }

    // Days of the week
    var weekdays: [String] {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols
    }
}

// View for each day cell in the calendar
struct DayCellView: View {
    let date: Date
    let hasMealPlan: Bool

    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.title3)
                .bold()
                .foregroundColor(hasMealPlan ? .green : .primary)  // Highlight days with meal plans
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hasMealPlan ? Color.green.opacity(0.1) : Color.clear)
                .cornerRadius(10)
        }
        .frame(height: 40)
    }
}

#Preview {
    CalendarView()
}
