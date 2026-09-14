//
//  TakeDogPhotoIntent.swift
//  Peticle
//
//  Created by Claire on 28/02/2026.
//

#if os(iOS)
import AppIntents
import Foundation

/// CameraCaptureIntent: Makes Peticle available as a Camera quick action.
/// When invoked, opens the app to the Add Dog view where the user can capture or select a photo.
///
/// Note: A full CameraCaptureIntent implementation requires a Camera Capture Extension target.
/// This implementation opens the main app as a pragmatic alternative, demonstrating
/// the protocol conformance pattern and AppContext usage.
struct TakeDogPhotoIntent: CameraCaptureIntent {
    static var title: LocalizedStringResource = "Take Dog Photo"
    static var description = IntentDescription(
        "Capture a photo of your dog from the Camera quick action."
    )

    typealias AppContext = DogPhotoContext

    static var appContext: DogPhotoContext? {
        get async throws {
            if let idString = UserDefaults.standard.string(forKey: "lastSelectedDogID"),
               let uuid = UUID(uuidString: idString) {
                return DogPhotoContext(selectedDogID: uuid)
            }
            return DogPhotoContext()
        }
    }

    static let supportedModes: IntentModes = [.foreground(.immediate)]

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let navigationManager: NavigationManager = AppDependencyManager.shared.get() else {
            throw IntentError.message("Unable to open camera. Please try again.")
        }

        navigationManager.navigateToRoot()
        navigationManager.shouldShowSecretFeature = true

        return .result()
    }
}

/// AppContext passed between the app and the capture extension.
/// Must be Codable, Sendable, and encode to < 4KB JSON.
struct DogPhotoContext: Codable, Sendable {
    var selectedDogID: UUID?
    var timestamp: Date

    init(selectedDogID: UUID? = nil) {
        self.selectedDogID = selectedDogID
        self.timestamp = .now
    }
}
#endif
