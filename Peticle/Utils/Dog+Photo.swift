//
//  Dog+Photo.swift
//  Peticle
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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
