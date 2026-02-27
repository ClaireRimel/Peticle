//
//  InteractionRating+Extentions.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

extension WalkQuality {
    func getWeatherIcon() -> Image {
        switch self {
            case .ok:
                return Image(systemName: "moon.zzz.fill")
            case .bad:
                return Image(systemName: "cloud.bolt.rain.fill")
            case .good:
                return Image(systemName: "sun.max.fill")
            case .wonderful:
                return Image(systemName: "rainbow")
        }
    }
}
