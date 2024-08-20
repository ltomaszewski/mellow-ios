//
//  CalendarDayView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI

struct CalendarDayView: View {
    private let hourSlotHeight: CGFloat = 48
    @ObservedObject var viewModel: CalendarDayViewModel
    
    init(date: Binding<Date?>, databaseStore: DatabaseStore) {
        _viewModel = ObservedObject(wrappedValue: CalendarDayViewModel(date: date, databaseStore: databaseStore))
    }
    
    var body: some View {
        GeometryReader { geometryProxy in // allows for offset to make scroll in center of the screen
            ScrollViewReader { scrollViewProxy in // allows for scroll to date
                ScrollView(.vertical) {
                    ZStack {
                        VStack(spacing: 0) {
                            // TODO: Current tiem indicator
                            ForEach(viewModel.hours, id: \.self) { date in
                                DayHourSlotView(date: date)
                                    .frame(height:hourSlotHeight)
                                    .id(date)
                            }
                        }
                        VStack(spacing: 0) {
                            ForEach(viewModel.sleepSessionsEntries, id: \.self) { model in
                                Rectangle()
                                    .frame(height: model.topOffset)
                                    .foregroundColor(.clear)
                                HStack {
                                    SleepSessionEntryView(model: model)
                                        .frame(height: model.height)
                                }
                                .padding(.leading, 76)
                                .padding(.trailing, 4)
                            }
                            Spacer()
                        }
                    }
                }.onAppear(perform: {
                    let capacity = geometryProxy.frame(in: .local).height/48
                    let midScreenOffset = Int(capacity/2)
                    scrollViewProxy.scrollTo(viewModel.midDayDate.adding(hours: midScreenOffset))
                })
            }
        }
    }
}
