//
//  peticleWidgetLiveActivity.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct PeticleWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var emoji: String
    }

    public var name: String

    public init(name: String) {
        self.name = name
    }
}

struct PeticleWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PeticleWidgetAttributes.self) { context in
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

extension PeticleWidgetAttributes {
    fileprivate static var preview: PeticleWidgetAttributes {
        PeticleWidgetAttributes(name: "World")
    }
}

public extension PeticleWidgetAttributes.ContentState {
    static var smiley: PeticleWidgetAttributes.ContentState {
            .init(emoji: "😀")
        }
     
      static var starEyes: PeticleWidgetAttributes.ContentState {
         PeticleWidgetAttributes.ContentState(emoji: "🤩")
     }
}

