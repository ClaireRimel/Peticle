//
//  peticleWidgetLiveActivity.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct peticleWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct peticleWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: peticleWidgetAttributes.self) { context in
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

extension peticleWidgetAttributes {
    fileprivate static var preview: peticleWidgetAttributes {
        peticleWidgetAttributes(name: "World")
    }
}

extension peticleWidgetAttributes.ContentState {
    fileprivate static var smiley: peticleWidgetAttributes.ContentState {
        peticleWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: peticleWidgetAttributes.ContentState {
         peticleWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: peticleWidgetAttributes.preview) {
   peticleWidgetLiveActivity()
} contentStates: {
    peticleWidgetAttributes.ContentState.smiley
    peticleWidgetAttributes.ContentState.starEyes
}
