//
//  Accessibility.swift
//  Peticle
//
//  Ported from the Habanera design system.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Reduce Motion

extension Animation {
    /// The animation, or `nil` (instant) when the system Reduce Motion
    /// setting is on: `withAnimation(PeticleTheme.Animation.snappy.reduceMotionAware)`.
    @MainActor
    var reduceMotionAware: Animation? {
        #if canImport(UIKit)
        UIAccessibility.isReduceMotionEnabled ? nil : self
        #elseif canImport(AppKit)
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? nil : self
        #else
        self
        #endif
    }
}

extension View {
    /// `.contentTransition(.numericText())` unless Reduce Motion is on —
    /// the digit roll is motion and must yield.
    func numericContentTransition() -> some View {
        modifier(NumericContentTransitionModifier())
    }
}

private struct NumericContentTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.contentTransition(reduceMotion ? .identity : .numericText())
    }
}

// MARK: - Reduce Transparency / Increase Contrast aware glass

extension View {
    /// Drop-in for `.glassEffect(_:in:)` that becomes an opaque surface
    /// when Reduce Transparency or Increase Contrast is on — Liquid Glass
    /// over glass drops legibility below WCAG AA for those users.
    func peticleGlass(
        _ glass: Glass = .regular,
        in shape: some Shape = RoundedRectangle(
            cornerRadius: PeticleTheme.Radius.large,
            style: .continuous
        )
    ) -> some View {
        modifier(PeticleGlassModifier(glass: glass, shape: AnyShape(shape)))
    }
}

private struct PeticleGlassModifier: ViewModifier {
    let glass: Glass
    let shape: AnyShape

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        if reduceTransparency || contrast == .increased {
            content
                .background(.background.secondary, in: shape)
                .overlay(shape.stroke(.separator, lineWidth: 1))
        } else {
            content.glassEffect(glass, in: shape)
        }
    }
}
