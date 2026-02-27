//
//  AddDogView.swift
//  Peticle
//
//  Created by Claire on 07/09/2025.
//

import SwiftUI
import PhotosUI
import AppIntents

struct AddDogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dogName: String = ""
    @State private var dogAge: Int = 0
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    /// A binding to a user preference indicating whether they hide the Siri tip.
    @AppStorage("displayAddDogSiriTip") private var displaySiriTip: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dog Information") {
                    TextField("Dog Name", text: $dogName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Stepper("Age: \(dogAge) years", value: $dogAge, in: 0...30)
                }
                
                Section("Photo") {
                    if let selectedImageData = selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label("Select Photo", systemImage: "photo")
                    }
                    .onChange(of: selectedImage) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }

                // SiriTipView: Shows the Siri phrase for adding a dog, helping users discover the voice shortcut
                Section {
                    SiriTipView(intent: AddDogIntent(), isVisible: $displaySiriTip)
                }
            }
            .navigationTitle("Add New Dog")
            .navigationBarTitleDisplayMode(.inline)
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
    
    private func saveDog() {
        guard !dogName.isEmpty else { return }
        
        do {
            _ = try DataModelHelper.addDog(
                name: dogName,
                imageData: selectedImageData,
                age: dogAge
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
