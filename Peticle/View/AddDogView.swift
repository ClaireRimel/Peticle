//
//  AddDogView.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import SwiftUI
import PhotosUI
import AppIntents
import SwiftData

struct AddDogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dogName: String = ""
    @State private var breed: Breed?
    @State private var dogDescription = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""

    /// A binding to a user preference indicating whether they hide the Siri tip.
    @AppStorage("displayAddDogSiriTip") private var displaySiriTip: Bool = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PeticleTheme.Spacing.xl) {
                    photoPicker

                    GlassSection("Dog Information") {
                        VStack(spacing: 0) {
                            TextField("Dog Name", text: $dogName)
                                .font(.body)
                                .padding(PeticleTheme.Spacing.lg)

                            Divider()
                                .padding(.leading, PeticleTheme.Spacing.lg)

                            // The picker style shows only the value: the label
                            // sits next to it so "None" isn't left alone.
                            HStack {
                                Text("Breed")
                                    .font(.body)
                                Spacer()
                                Picker("Breed", selection: $breed) {
                                    Text("None").tag(Breed?.none)
                                    ForEach(Breed.allCases, id: \.self) { breed in
                                        Text(breed.localizedStringResource)
                                            .tag(Breed?.some(breed))
                                    }
                                }
                                .labelsHidden()
                            }
                            .padding(PeticleTheme.Spacing.lg)




                            Divider()
                                .padding(.leading, PeticleTheme.Spacing.lg)

                            TextField("Description", text: $dogDescription, axis: .vertical)
                                .font(.body)
                                .lineLimit(3...6)
                                .padding(PeticleTheme.Spacing.lg)
                        }
                    }

                    #if os(iOS)
                    // SiriTipView: Shows the Siri phrase for adding a dog, helping users discover the voice shortcut
                    SiriTipView(intent: TakeDogPhotoIntent(), isVisible: $displaySiriTip)
                    #endif
                }
                .padding(.horizontal, PeticleTheme.Spacing.lg)
                .padding(.vertical, PeticleTheme.Spacing.lg)
            }
            .navigationTitle("Add New Dog")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDog()
                    }
                    .disabled(dogName.isEmpty)
                }
            }
            .alert("Add Dog", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("Successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var photoPicker: some View {
        PhotosPicker(selection: $selectedImage, matching: .images) {
            VStack(spacing: PeticleTheme.Spacing.sm) {
                ZStack {
                    if let selectedImageData, let image = Image(imageData: selectedImageData) {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [.peticleChocolate, .peticleCaramel],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1)
                }

                Label("Select Photo", systemImage: "photo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedImage) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }

    private func saveDog() {
        guard !dogName.isEmpty else { return }

        do {
            _ = try DataModelHelper.addDog(
                name: dogName,
                imageData: selectedImageData,
                breed: breed,
                dogDescription: dogDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dogDescription
            )
            alertMessage = "Successfully added \(dogName) to your pet collection!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to add dog: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    AddDogView()
}
