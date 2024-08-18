//
//  TodayTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @EnvironmentObject var databaseStore: DatabaseStore
    @State var day: Date? = Date.now.adjustToMidday()
    @State private var showAddSleepSession = false
    @State private var sheetHeight: CGFloat = 300
    
    var body: some View {
        ZStack {
            VStack {
                DayPickerBarView(date: $day)
                    .frame(height: 64)
                CalendarDayView(date: $day,
                                databaseStore: databaseStore)
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
            AddSleepView(date: day ?? .now)
            .fixedSize(horizontal: false, vertical: true)
            .modifier(GetHeightModifier(height: $sheetHeight))
            .presentationDetents([.height(CGFloat(sheetHeight))])
        })
        .background(Color("gunmetalBlue"))
    }
}

#Preview {
    TodayTabView()
}

struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                height = geo.size.height
                return Color.clear
            }
        )
    }
}
