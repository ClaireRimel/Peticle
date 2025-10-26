//
//  peticleWidgetControl.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct OpenSecretViewControl: ControlWidget {
    static let kind: String = "com.Yo.Peticle.Secret"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenSecretViewWalkIntent()) {
                Label("Show Secret", systemImage: "lock.fill")
            }
        }
        .displayName("Show Secret")
        .description("Use to Display the secret view")
    }
}
