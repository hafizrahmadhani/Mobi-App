//
//  CameraPreviewView.swift
//  Mobi
//
//  Created by Muhammad Al Hafiz Rahmadhani on 05/11/25.
//

// CameraPreviewView.swift
import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    
    // Sesi kamera yang didapat dari ViewModel
    let session: AVCaptureSession
    
    // Membuat View UIKit
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        
        // Set layer preview kamera
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.previewLayer = previewLayer
        
        return view
    }
    
    // Memperbarui View UIKit (tidak kita gunakan)
    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        // Tidak perlu update
    }
    
    // Custom UIView untuk menghandle layoutSubviews
    // Ini penting agar preview kamera bisa resize
    class PreviewUIView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            // Pastikan frame preview layer selalu mengisi view
            previewLayer?.frame = self.bounds
        }
    }
}
