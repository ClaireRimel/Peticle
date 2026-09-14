//
//  InteractionRating+Extentions.swift
//  Peticle
//
//  Created by Claire on 18/05/2025.
//

import SwiftUI

extension WalkQuality {
    /// Order shown in the quality picker, from worst to best.
    static let displayOrder: [WalkQuality] = [.bad, .ok, .good, .wonderful]

    /// Habanera illustration: Habanera in light mode, Alfie in dark mode.
    var imageAssetName: String {
        switch self {
        case .bad: "QualityBad"
        case .ok: "QualityOk"
        case .good: "QualityGood"
        case .wonderful: "QualityWonderful"
        }
    }

    var label: LocalizedStringKey {
        switch self {
        case .bad: "Bad"
        case .ok: "OK"
        case .good: "Good"
        case .wonderful: "Wonderful"
        }
    }
}
