//
//  TodayTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @EnvironmentObject var databaseStore: DatabaseStore
    @State var day: Date = Date.now.adjustToMidday()
    @State private var showAddSleepSession = false
    @State private var sheetHeight: CGFloat = 300
    @State private var sheetWidth: CGFloat = 300
    
    var body: some View {
        ZStack {
            VStack {
                DayPickerBarView(date: $day)
                    .frame(height: 64)
                CalendarDayViewWithPager(databaseStore: databaseStore, day: $day)
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showAddSleepSession = true
                        }
                    }, label: {
                        Image("moon_blue") // Use your desired image here
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64) // Set the size of the image
                    })
                    .buttonStyle(PlainButtonStyle()) // Optional: Customize the button style
                }.padding([.trailing,.bottom], 16)
            }
        }
        .sheet(isPresented: $showAddSleepSession, content: {
            AddSleepView(date: day,
                         width: $sheetWidth)
            .fixedSize(horizontal: false, vertical: true)
            .modifier(GetDimensionsModifier(height: $sheetHeight, width: $sheetWidth))
            .presentationDetents([.height(CGFloat(sheetHeight))])
        })
        .background(Color("gunmetalBlue"))
    }
}

#Preview {
    TodayTabView()
}

struct GetDimensionsModifier: ViewModifier {
    @Binding var height: CGFloat
    @Binding var width: CGFloat
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                height = geo.size.height
                width = geo.size.width
                return Color.clear
            }
        )
    }
}
