//
//  mellow_widgetLiveActivity.swift
//  mellow-widget
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MellowWidgetLiveActivity: Widget {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MellowWidgetAttributes.self) { context in
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(context.state.name) is a sleep for")
                            .font(.system(size: 12))
                            .foregroundColor(Color("mellowWhite"))
                        Text(context.state.startDate, style: .timer)
                            .font(.system(size: 32))
                            .foregroundColor(Color("mellowWhite"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Estimated wakeup")
                            .font(.system(size: 12))
                            .foregroundColor(Color("mellowWhite"))
                        Text(context.state.expectedEndDate, style: .time)
                            .font(.system(size: 18))
                            .foregroundColor(Color("mellowWhite"))
                        Spacer()
                    }
                }
                
                ProgressView(
                    timerInterval: context.state.startDate...context.state.expectedEndDate,
                    countsDown: false,
                    label: { },
                    currentValueLabel: { EmptyView() }
                )
                .tint(Color(cgColor: .init(red: 90.0 / 255.0, green: 108.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }
            } compactLeading: {
                Text("\(context.state.name)")
                    .padding()
            } compactTrailing: {
                Text(context.state.startDate, style: .timer)
                    .frame(width: 64)
                    .minimumScaleFactor(1.0)
            } minimal: {
                Text(context.state.name.prefix(1))
            }
            .keylineTint(Color.white)
        }
    }
}

struct TimerView: View {
    let startDate: Date
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let elapsedTime = context.date.timeIntervalSince(startDate)
            Text(elapsedTime.formattedTime)
        }
    }
}

private extension TimeInterval {
    var formattedTime: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension MellowWidgetAttributes {
    fileprivate static var preview: MellowWidgetAttributes {
        MellowWidgetAttributes(title: "Sleep Session")
    }
}

extension MellowWidgetAttributes.ContentState {
    fileprivate static var preview: MellowWidgetAttributes.ContentState {
        MellowWidgetAttributes.ContentState(name: "Nick", startDate: .now, expectedEndDate: Date().addingTimeInterval(400))
    }
}

#Preview("Notification", as: .content, using: MellowWidgetAttributes.preview) {
    MellowWidgetLiveActivity()
} contentStates: {
    MellowWidgetAttributes.ContentState.preview
}


#Preview("Notification", as: .dynamicIsland(.minimal), using: MellowWidgetAttributes.preview) {
    MellowWidgetLiveActivity()
} contentStates: {
    MellowWidgetAttributes.ContentState.preview
}
