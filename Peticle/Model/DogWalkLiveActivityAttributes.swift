//
//  DogWalkLiveActivityAttributes.swift
//  Peticle
//
//  Created by Claire on 11/05/2025.
//

import Foundation
import ActivityKit

public struct PeticleWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var elapsedTime: Int
        public var goalTime: Int
        public var isActive: Bool
    }

    public var walkName: String

    public init(walkName: String) {
        self.walkName = walkName
    }
}

