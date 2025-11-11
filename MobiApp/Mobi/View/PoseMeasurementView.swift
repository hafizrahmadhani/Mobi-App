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
    }
}

#Preview {
    PoseMeasurementView(side: .left)
}
