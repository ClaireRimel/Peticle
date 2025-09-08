//
//  InteractionRating+Extentions.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

extension InteractionRating {
    func getFusionnedWeatherIcon(with other: InteractionRating) -> Image {
        switch (self, other) {
        case (.none, _), (_, .none):
            return Image(systemName: "moon.zzz.fill")
        case (.good, .bad), (.bad, .good):
            return Image(systemName: "sun.max.fill")
        case (.good, _), (_, .good):
            return Image(systemName: "rainbow")
        case (.average, _), (_, .average):
            return Image(systemName: "sun.max.fill")
        case (.bad, _), (_, .bad):
            return Image(systemName: "cloud.bolt.rain.fill")
        default:
            return Image(systemName: "smoke.fill")
        }
    }
}
