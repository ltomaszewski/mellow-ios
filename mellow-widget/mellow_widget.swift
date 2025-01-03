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
                HStack {
                    VStack(alignment: .leading) {
                        Text("Sleep in progress...")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        Text(session.startDate, style: .time)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("End")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .cornerRadius(10)
                    }
                }
            } else {
                VStack {
                    Text("No Active Sleep Session")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .padding()
            }
        }
        .containerBackground(for: .widget) { Color.blue }
    }
}

struct MellowWidget: Widget {
    let kind: String = "MellowWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MellowWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Mellow Sleep Tracker")
        .description("Track your ongoing sleep sessions.")
    }
}

#Preview(as: .systemMedium) {
    MellowWidget()
} timeline: {
    Entry(date: .now, sessionData: .init(name: "Nick", startDate: .now, type: "Sleeping..."))
    Entry(date: .now, sessionData: nil)
}
