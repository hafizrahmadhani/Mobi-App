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
    
    @Published var angleText: String = "Start Moving!"
    @Published var detectedJoints: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
    @Published var sideToMeasure: ShoulderSide
    
    let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput!
    private var visionRequest: VNDetectHumanBodyPoseRequest!
    let capturePublisher = PassthroughSubject<(UIImage, [VNHumanBodyPoseObservation.JointName : CGPoint], Int), Never>()
    
    private var lastAngle: CGFloat?
    private var stabilityCounter: Int = 0
    private let stabilityThreshold: Int = 60
    
    private var hasCaptured: Bool = false
    private var captureTriggered: Bool = false
    private var currentStableAngle: Int = 0
    private let context = CIContext()
    private var jointsToCapture: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
    private var angleToCapture: Int = 0
    
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
                self.angleText = "Camera Access Denied"
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
            DispatchQueue.main.async { self.angleText = "Front Camera not Found" }
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
            print("Camera Setup Error \(error.localizedDescription)")
            DispatchQueue.main.async { self.angleText = "Camera Error" }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if captureTriggered && !hasCaptured {
            captureTriggered = false
            hasCaptured = true
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }
            
            let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            guard let flippedImage = image.flippedHorizontally() else { return }
            
            let joints = self.jointsToCapture
            let angle = self.angleToCapture
            
            DispatchQueue.main.async {
                self.capturePublisher.send((flippedImage, joints, angle))
                self.stopSession()
            }
        }
        
        if !hasCaptured {
            let orientation = CGImagePropertyOrientation.right
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                orientation: orientation,
                                                options: [:])
            do {
                try handler.perform([visionRequest])
            } catch {
                print("Failed to perform Vision request: \(error)")
            }
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
        
        let angle: CGFloat
        
        if sideToMeasure == .left {
            guard let leftHip = recognizedPoints[.leftHip],
                  let leftShoulder = recognizedPoints[.leftShoulder],
                  let leftWrist = recognizedPoints[.leftWrist],
                  leftHip.confidence > 0.1 && leftShoulder.confidence > 0.1 && leftWrist.confidence > 0.1 else {
                
                DispatchQueue.main.async { self.angleText = "Left shoulder in Position" }
                self.stabilityCounter = 0
                self.lastAngle = nil
                return
            }
            angle = calculateAngle(p1: leftHip.location, p2: leftShoulder.location, p3: leftWrist.location)
            
        } else {
            guard let rightHip = recognizedPoints[.rightHip],
                  let rightShoulder = recognizedPoints[.rightShoulder],
                  let rightWrist = recognizedPoints[.rightWrist],
                  rightHip.confidence > 0.1 && rightShoulder.confidence > 0.1 && rightWrist.confidence > 0.1 else {
                
                DispatchQueue.main.async { self.angleText = "Right shoulder in Position" }
                self.stabilityCounter = 0
                self.lastAngle = nil
                return
            }
            angle = calculateAngle(p1: rightHip.location, p2: rightShoulder.location, p3: rightWrist.location)
        }
        
        let roundedAngle = Int(angle)
        
        DispatchQueue.main.async {
            if !self.hasCaptured {
                self.angleText = "\(self.sideToMeasure == .left ? "Left" : "Right"): \(roundedAngle)°"
            }
        }
        
        if abs(angle - (lastAngle ?? 0)) < 2.0 {
            stabilityCounter += 1
        } else {
            stabilityCounter = 0
        }
        lastAngle = angle
        
        if stabilityCounter > stabilityThreshold && !hasCaptured && angle > 15.0 {
            
            self.angleToCapture = roundedAngle
            self.jointsToCapture = self.detectedJoints
            
            self.currentStableAngle = roundedAngle
            self.captureTriggered = true
            
            DispatchQueue.main.async {
                self.angleText = "Hold it... \(roundedAngle)°"
            }
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
