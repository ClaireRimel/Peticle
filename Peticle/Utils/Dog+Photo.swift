//
//  Dog+Photo.swift
//  Peticle
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Image {
    /// Builds an image from raw photo data on any platform.
    init?(imageData: Data) {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: imageData) else { return nil }
        self.init(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: imageData) else { return nil }
        self.init(nsImage: nsImage)
        #endif
    }
}

extension Dog {
    #if canImport(UIKit)
    var photo: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
    #elseif canImport(AppKit)
    var photo: NSImage? {
        guard let imageData else { return nil }
        return NSImage(data: imageData)
    }
    #endif
}
