//
//  InteractionRating+Extentions.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

extension InteractionRating {
    func getWeatherIcon() -> Image {
        switch self {
        case .none:
            return Image(systemName: "moon.zzz.fill")
        case .bad:
            return Image(systemName: "cloud.bolt.rain.fill")
        case .average:
            return Image(systemName: "sun.max.fill")
        case .good:
            return Image(systemName: "rainbow")
        }
    }
}
