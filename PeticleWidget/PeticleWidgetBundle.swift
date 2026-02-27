//
//  peticleWidgetBundle.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import WidgetKit
import SwiftUI

@main
struct peticleWidgetBundle: WidgetBundle {
    var body: some Widget {
        OpenSecretViewControl()
        PeticleWidgetLiveActivity()
        PeticleQuickActionsWidget()
    }
}
