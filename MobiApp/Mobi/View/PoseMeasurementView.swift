//
//  PoseMeasurementView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 08/11/25.
//

import SwiftUI

struct PoseMeasurementView: View {
    
    let side: ShoulderSide
    @StateObject private var viewModel: PoseViewModel
    
    @EnvironmentObject var historyViewModel: HistoryViewModel
        // 2. Akses presentationMode untuk kembali (dismiss)
        @Environment(\.presentationMode) var presentationMode
    
    init(side: ShoulderSide) {
        self.side = side
        _viewModel = StateObject(wrappedValue: PoseViewModel(sideToMeasure: side))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    CameraPreviewView(session: viewModel.captureSession)
                    JointView(joints: viewModel.detectedJoints)
                }
                .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fit)
                .frame(width: geometry.size.width)
                .clipped()
                Spacer()
            }
            .background(Color.black)
            .ignoresSafeArea()
            
            .overlay(
                AngleOverlayView(angleText: viewModel.angleText),
                alignment: .bottom
            )
        }
        .onAppear {
            viewModel.checkCameraPermission()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .navigationBarBackButtonHidden(false)
        // ... di PoseMeasurementView.swift

        .onReceive(viewModel.capturePublisher) { (rawImage, joints, angle) in
            
            let originalSize = rawImage.size // misal: 1080x1920 (9:16)
            
            // 1. Tentukan ukuran target 3:4
            let targetRatio: CGFloat = 3.0 / 4.0 // 0.75
            let newHeight = originalSize.width / targetRatio // 1080 / 0.75 = 1440
            let newSize = CGSize(width: originalSize.width, height: newHeight) // 1080x1440
            
            // 2. Buat "Snapshot View" (Ukuran 3:4)
            let snapshotView = ZStack {
                
                // 1. Gambar Background
                Image(uiImage: rawImage)
                    .resizable()
                    .scaledToFill() // <-- INI PENTING
                
                // 2. Overlay Joint
                JointView(joints: joints)
                    // Beri ukuran asli 9:16
                    .frame(width: originalSize.width, height: originalSize.height)
                    // Terapkan transform Yg SAMA agar pas
                    .scaledToFill() // <-- INI PENTING
            }
            // "Jendela" snapshot kita adalah 3:4
            .frame(width: newSize.width, height: newSize.height, alignment: .center)
            .clipped()
            .ignoresSafeArea()

            
            // 3. Ambil Snapshot (Gunakan fungsi dari View+Snapshot.swift)
            let finalImage = snapshotView.snapshot(size: newSize)
            
            // 4. PANGGIL FUNGSI BARU HISTORYVIEWMODEL
            historyViewModel.addHistory(
                image: finalImage,
                side: self.side,
                angle: angle
            )
            
            // 5. Beri feedback
            viewModel.angleText = "Captured: \(angle)°!"
            
            // 6. Kembali ke MainPageView
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    PoseMeasurementView(side: .left)
        .environmentObject(HistoryViewModel())
}
