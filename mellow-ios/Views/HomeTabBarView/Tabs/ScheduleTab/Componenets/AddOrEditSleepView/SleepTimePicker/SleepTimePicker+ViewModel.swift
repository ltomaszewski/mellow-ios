//
//  SleepTimePicker+ViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 17/08/2024.
//

import SwiftUI

extension SleepTimePicker {
    class ViewModel: ObservableObject {
        @Published var date: Date? {
            didSet {
                formattedDate = formatDate()
            }
        }
        
        @Published var formattedDate: String = "Add Time"
        
        private let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter
        }()
        
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d h:mm a"
            return formatter
        }()
        
        init(date: Date? = nil) {
            self.date = date
            self.formattedDate = formatDate()
        }
        
        private func formatDate() -> String {
            guard let date = date else { return "Add Time" }
            
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                return "Today " + timeFormatter.string(from: date)
            } else {
                return dateFormatter.string(from: date)
            }
        }
    }
}
