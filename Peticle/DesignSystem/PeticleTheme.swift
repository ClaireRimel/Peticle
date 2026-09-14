//
//  PeticleTheme.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

/// Design tokens: spacing, corner radius, animation timings.
///
/// Brand colors live in `Assets.xcassets` (`peticle-chocolate`,
/// `peticle-brand`, `peticle-on-brand`…) and are reached through the
/// generated asset symbols (`Color.peticleBrand`). Each Color Set carries
/// light, dark and Increase Contrast variants.
enum PeticleTheme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 14
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 28
    }

    enum Animation {
        static let snappy: SwiftUI.Animation = .snappy(duration: 0.25)
        static let bouncy: SwiftUI.Animation = .bouncy(duration: 0.4)
        static let smooth: SwiftUI.Animation = .smooth(duration: 0.35)
    }
}
