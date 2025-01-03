//
//  mellow_widgetLiveActivity.swift
//  mellow-widget
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct mellow_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct mellow_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: mellow_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension mellow_widgetAttributes {
    fileprivate static var preview: mellow_widgetAttributes {
        mellow_widgetAttributes(name: "World")
    }
}

extension mellow_widgetAttributes.ContentState {
    fileprivate static var smiley: mellow_widgetAttributes.ContentState {
        mellow_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: mellow_widgetAttributes.ContentState {
         mellow_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: mellow_widgetAttributes.preview) {
   mellow_widgetLiveActivity()
} contentStates: {
    mellow_widgetAttributes.ContentState.smiley
    mellow_widgetAttributes.ContentState.starEyes
}
