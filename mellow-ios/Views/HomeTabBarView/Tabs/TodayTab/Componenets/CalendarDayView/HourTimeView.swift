//
//  HourTimeView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI

struct HourTimeView: View {
    let date: Date
    let hourAndMinute: String
    let amPm: String
    
    init(date: Date) {
        self.date = date
        let formatter = DateFormatter()
        formatter.dateFormat = "h:'00'"
        hourAndMinute = formatter.string(from: date).appending(" ")
        
        formatter.dateFormat = "a"
        amPm = formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Spacer()
            Text(hourAndMinute)
                .foregroundColor(Color.slate100)
                .font(.main12)
                .opacity(0.8)
            Text(amPm)
                .foregroundColor(Color.slate100)
                .font(.main10)
                .opacity(0.5)
        }
    }
}
