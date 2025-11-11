//
//  Snapshot.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import Foundation
import SwiftUI

extension View {
    // Kita modifikasi fungsi snapshot agar menerima ukuran (size)
    func snapshot(size targetSize: CGSize) -> UIImage {
        
        // 1. Buat 'controller' untuk menampung view
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        // 2. PAKSA view agar memiliki ukuran (bounds)
        //    sesuai 'targetSize' yang kita kirimkan.
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        // 3. Render view menjadi gambar
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
    
    // Kita simpan fungsi lama (tanpa parameter) jika Anda
    // membutuhkannya di tempat lain, tapi kita buat dia
    // memanggil fungsi baru dengan intrinsicContentSize.
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
