//
//  PoseViewModel.swift
//  Mobi
//
//  Created by Muhammad Al Hafiz Rahmadhani on 05/11/25.
//

import SwiftUI
import Combine
import AVFoundation
import Vision

class PoseViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var angleText: String = "Mulai Bergerak"
    @Published var detectedJoints: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
    @Published var sideToMeasure: ShoulderSide
    
    let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput!
    private var visionRequest: VNDetectHumanBodyPoseRequest!
    
    
    init(sideToMeasure: ShoulderSide) {
        self.sideToMeasure = sideToMeasure
        super.init()
        setupVision()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.angleText = "Izin kamera ditolak"
            }
        }
    }
    
    private func setupVision() {
        visionRequest = VNDetectHumanBodyPoseRequest(completionHandler: visionCompletionHandler)
        visionRequest.revision = VNDetectHumanBodyPoseRequestRevision1
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            DispatchQueue.main.async { self.angleText = "Kamera depan tidak ada" }
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue", qos: .userInitiated))
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
            
        } catch {
            print("Error setup kamera: \(error.localizedDescription)")
            DispatchQueue.main.async { self.angleText = "Error kamera" }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let orientation = CGImagePropertyOrientation.right
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: orientation,
                                            options: [:])
        do {
            try handler.perform([visionRequest])
        } catch {
            print("Gagal perform Vision request: \(error)")
        }
    }
    
    private func visionCompletionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let observation = observations.first else {
            return
        }
        
        processObservation(observation)
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
            DispatchQueue.main.async {
                self.detectedJoints = [:]
            }
            return
        }
       
        let jointsToDraw: [VNHumanBodyPoseObservation.JointName]
        if sideToMeasure == .left {
            jointsToDraw = [.leftShoulder, .leftElbow, .leftWrist]
        } else {
            jointsToDraw = [.rightShoulder, .rightElbow, .rightWrist]
        }
        
        var currentJoints: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
        for jointName in jointsToDraw {
            if let recognizedPoint = recognizedPoints[jointName], recognizedPoint.confidence > 0.1 {
                currentJoints[jointName] = recognizedPoint.location
            }
        }
        
        DispatchQueue.main.async {
            self.detectedJoints = currentJoints
        }
        
        if sideToMeasure == .left {
            guard let leftHip = recognizedPoints[.leftHip],
                  let leftShoulder = recognizedPoints[.leftShoulder],
                  let leftWrist = recognizedPoints[.leftWrist],
                  leftHip.confidence > 0.1 && leftShoulder.confidence > 0.1 && leftWrist.confidence > 0.1 else {
                
                DispatchQueue.main.async { self.angleText = "Posisikan Bahu Kiri" }
                return
            }
            
            let angle = calculateAngle(p1: leftHip.location, p2: leftShoulder.location, p3: leftWrist.location)
            DispatchQueue.main.async { self.angleText = "Left: \(Int(angle))°" }
            
        } else {
            guard let rightHip = recognizedPoints[.rightHip],
                  let rightShoulder = recognizedPoints[.rightShoulder],
                  let rightWrist = recognizedPoints[.rightWrist],
                  rightHip.confidence > 0.1 && rightShoulder.confidence > 0.1 && rightWrist.confidence > 0.1 else {
                
                DispatchQueue.main.async { self.angleText = "Posisikan Bahu Kanan" }
                return
            }
            
            let angle = calculateAngle(p1: rightHip.location, p2: rightShoulder.location, p3: rightWrist.location)
            DispatchQueue.main.async { self.angleText = "Right: \(Int(angle))°" }
        }
    }
    
    private func calculateAngle(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let v1 = (x: p1.x - p2.x, y: p1.y - p2.y)
        let v2 = (x: p3.x - p2.x, y: p3.y - p2.y)
        
        let dotProduct = (v1.x * v2.x) + (v1.y * v2.y)
        let magV1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let magV2 = sqrt(v2.x * v2.x + v2.y * v2.y)
        
        guard magV1 != 0, magV2 != 0 else { return 0.0 }
        
        let cosTheta = dotProduct / (magV1 * magV2)
        let clampedCosTheta = max(-1.0, min(1.0, cosTheta))
        let angleRad = acos(clampedCosTheta)
        let angleDeg = angleRad * (180.0 / .pi)
        
        return angleDeg
    }
}
