//
//  peticleWidgetControl.swift
//  peticleWidget
//
//  Created by Claire on 11/05/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct NewDogWalkControl: ControlWidget {
    static let kind: String = "com.Yo.Peticle.startWalk"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind){
            ControlWidgetButton(action: NewDogWalkIntent()) {
                Label("Create Entry", systemImage: "square.and.arrow.down")
            }
        }
        .displayName("Compose")
        .description("A control that starts register a new walk activity")
    }
}

struct AddDetailsControl: ControlWidget {
    static let kind: String = "com.Yo.Peticle.addDetails"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: AddDetailDogWalkIntent()) {
                Label("Add Detail", systemImage: "pencil")
                
            }
        }
        .displayName("Modify")
        .description("Add details to your last walk")
    }
}
