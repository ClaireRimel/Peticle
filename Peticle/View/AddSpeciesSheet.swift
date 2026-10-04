//
//  AddSpeciesSheet.swift
//  Peticle
//

import SwiftUI

/// Creates a species with a name and a symbol. The symbol list is
/// SpeciesSymbol, the same one Shortcuts offers in "Add a Pet".
struct AddSpeciesSheet: View {
    let onCreate: (SpeciesEntity) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var symbol: SpeciesSymbol = .other
    @State private var errorMessage: String?

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: PeticleTheme.Spacing.md)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PeticleTheme.Spacing.xl) {
                    GlassSection("Species") {
                        TextField("Name, like Cat", text: $name)
                            .font(.body)
                            .padding(PeticleTheme.Spacing.lg)
                    }

                    GlassSection("Symbol") {
                        LazyVGrid(columns: columns, spacing: PeticleTheme.Spacing.md) {
                            ForEach(SpeciesSymbol.allCases, id: \.self) { option in
                                symbolButton(option)
                            }
                        }
                        .padding(PeticleTheme.Spacing.lg)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(PeticleTheme.Spacing.lg)
            }
            .navigationTitle("New species…")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func symbolButton(_ option: SpeciesSymbol) -> some View {
        let isSelected = option == symbol
        return Button {
            symbol = option
        } label: {
            Image(systemName: option.rawValue)
                .font(.title2)
                .frame(width: 56, height: 56)
                .foregroundStyle(isSelected ? Color.peticleOnBrand : Color.primary)
                .background(
                    isSelected ? Color.peticleBrand : Color.secondary.opacity(0.12),
                    in: .rect(cornerRadius: PeticleTheme.Radius.medium)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(option.localizedStringResource))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func save() {
        do {
            let species = try DataModelHelper.createSpecies(name: name, symbol: symbol)
            onCreate(species)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
