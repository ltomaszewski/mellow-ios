//
//  mellow_widget.swift
//  mellow-widget
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let sessionManager = SharedSleepSessionUserDefaultsManager()
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), sessionData: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let sessionData = sessionManager.loadSharedSleepSession()
        completion(Entry(date: Date(), sessionData: sessionData))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let sessionData = sessionManager.loadSharedSleepSession()
        let entry = Entry(date: currentDate, sessionData: sessionData)
        
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let sessionData: SharedSleepSessionData?
}

struct MellowWidgetEntryView: View {
    var entry: Entry
    
    var body: some View {
        Group {
            if let session = entry.sessionData {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(session.name) is a sleep for")
                                .font(.system(size: 12))
                                .foregroundColor(Color("mellowWhite"))
                            Text(session.startDate, style: .timer)
                                .font(.system(size: 32))
                                .foregroundColor(Color("mellowWhite"))
                            Spacer()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Estimated wakeup")
                                .font(.system(size: 12))
                                .foregroundColor(Color("mellowWhite"))
                            Text(session.expectedEndDate, style: .time)
                                .font(.system(size: 18))
                                .foregroundColor(Color("mellowWhite"))
                            Spacer()
                        }
                    }
                    
                    ProgressView(
                        timerInterval: session.startDate...session.expectedEndDate,
                        countsDown: false,
                        label: { },
                        currentValueLabel: { EmptyView() }
                    )
                    .tint(Color(cgColor: .init(red: 90.0 / 255.0, green: 108.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
            } else {
                VStack {
                    Text("No Active Sleep Session")
                        .font(.headline)
                        .foregroundColor(Color("mellowWhite"))
                }
                .padding()
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

struct MellowWidget: Widget {
    let kind: String = "MellowWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MellowWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Mellow Sleep Tracker")
        .description("Track your ongoing sleep sessions.")
    }
}

#Preview(as: .systemMedium) {
    MellowWidget()
} timeline: {
    Entry(date: .now, sessionData: .init(name: "Nick",
                                         startDate: .now,
                                         expectedEndDate: Date().addingTimeInterval(400),
                                         type: "Sleeping..."))
    Entry(date: .now, sessionData: nil)
}
