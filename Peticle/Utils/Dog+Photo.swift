//
//  Dog+Photo.swift
//  Peticle
//

import UIKit

extension Dog {
    var photo: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
}
