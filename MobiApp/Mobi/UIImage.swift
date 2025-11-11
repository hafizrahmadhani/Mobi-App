//
//  UIImage.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import Foundation
import UIKit

extension UIImage {
    
    // Fungsi untuk membalik gambar secara horizontal
    func flippedHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Pindahkan origin ke kanan
        context.translateBy(x: self.size.width, y: 0)
        // Balik (scale) sumbu x
        context.scaleBy(x: -1.0, y: 1.0)
        
        // Gambar
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
