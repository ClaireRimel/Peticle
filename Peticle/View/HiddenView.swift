//
//  HidenView.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import SwiftUI

struct HiddenView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: PeticleTheme.Spacing.lg) {
            GlassCard(cornerRadius: PeticleTheme.Radius.xlarge) {
                VStack(spacing: PeticleTheme.Spacing.md) {
                    Text("You found me!")
                        .font(.title.weight(.semibold))

                    Image("Lindo Alfie")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: PeticleTheme.Radius.large, style: .continuous))

                    Text("I'm not a bug, I'm a feature ✨")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
            }

            GlassPrimaryButton("Go Back") {
                dismiss()
            }
        }
        .padding(PeticleTheme.Spacing.lg)
    }
}
