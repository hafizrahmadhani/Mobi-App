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
        .onReceive(viewModel.capturePublisher) { (rawImage, joints, angle) in
            
            let originalSize = rawImage.size
            let targetRatio: CGFloat = 3.0 / 4.0
            let newHeight = originalSize.width / targetRatio
            let newSize = CGSize(width: originalSize.width, height: newHeight)
            let snapshotView = ZStack {
                
                Image(uiImage: rawImage)
                    .resizable()
                    .scaledToFill()
                
                JointView(joints: joints)
                    .frame(width: originalSize.width, height: originalSize.height)
                    .scaledToFill()
            }
                .frame(width: newSize.width, height: newSize.height, alignment: .center)
                .clipped()
                .ignoresSafeArea()
            
            let finalImage = snapshotView.snapshot(size: newSize)
            
            historyViewModel.addHistory(
                image: finalImage,
                side: self.side,
                angle: angle
            )
            
            viewModel.angleText = "Captured: \(angle)°!"
            
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
