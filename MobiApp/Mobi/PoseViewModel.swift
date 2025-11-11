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

import SwiftUI
import Combine
import AVFoundation
import Vision

class PoseViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Properti yang sudah ada
    @Published var angleText: String = "Start Moving!"
    @Published var detectedJoints: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
    @Published var sideToMeasure: ShoulderSide
    
    let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput!
    private var visionRequest: VNDetectHumanBodyPoseRequest!
    
    // --- TAMBAHAN BARU UNTUK CAPTURE OTOMATIS ---
    
    // Publisher untuk mengirim data (HistoryItem) saat gambar ditangkap
    // View (PoseMeasurementView) akan "mendengarkan" ini
    let capturePublisher = PassthroughSubject<(UIImage, [VNHumanBodyPoseObservation.JointName : CGPoint], Int), Never>()

    // Properti untuk mendeteksi stabilitas
    private var lastAngle: CGFloat?
    private var stabilityCounter: Int = 0
    // Jumlah frame untuk dianggap stabil.
    // Sesuaikan angka ini jika dirasa terlalu cepat/lambat.
    // 60 frame ~ 1-2 detik, tergantung FPS kamera.
    private let stabilityThreshold: Int = 60
    
    // Properti untuk proses capture
    private var hasCaptured: Bool = false      // Mencegah capture berulang kali
    private var captureTriggered: Bool = false // Sinyal untuk mengambil gambar di frame berikutnya
    private var currentStableAngle: Int = 0  // Menyimpan sudut saat stabil
    private let context = CIContext()        // Untuk konversi CVPixelBuffer ke UIImage
    private var jointsToCapture: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
    private var angleToCapture: Int = 0
    
    // --- AKHIR TAMBAHAN ---
    
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
    
    // Fungsi ini dipanggil untuk SETIAP frame dari kamera
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // --- LOGIC CAPTURE BARU ---
        // Cek apakah trigger aktif dan belum capture
        if captureTriggered && !hasCaptured {
            captureTriggered = false
            hasCaptured = true

            // 1. Konversi CVPixelBuffer ke CIImage
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

            // 2. Buat CGImage
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }

            // 3. Buat UIImage dengan orientasi yang benar
            let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)

            // 4. Balik gambar secara horizontal
            guard let flippedImage = image.flippedHorizontally() else { return }

            // 5. Ambil data joints & angle yang sudah disimpan
            let joints = self.jointsToCapture
            let angle = self.angleToCapture

            // 6. Kirim DATA MENTAH (bukan HistoryItem) ke View
            DispatchQueue.main.async {
                // Kirim gambar, data joint, dan angle
                self.capturePublisher.send((flippedImage, joints, angle))
                self.stopSession() // Hentikan session setelah berhasil
            }
        }
        // --- AKHIR LOGIC CAPTURE ---

        // Kita tetap perlu menjalankan Vision request
        // Pastikan ini dieksekusi HANYA jika belum capture
        // agar proses deteksi berhenti setelah capture
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
    
    // Fungsi ini dipanggil setelah Vision selesai memproses frame
    private func visionCompletionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let observation = observations.first else {
            return
        }
        
        // Kirim observasi ke fungsi processing
        processObservation(observation)
    }
    
    // Fungsi untuk memproses hasil deteksi pose
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
            DispatchQueue.main.async {
                self.detectedJoints = [:]
            }
            return
        }
        
        // Bagian untuk menggambar skeleton (tidak berubah)
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
        
        // Variabel untuk menyimpan sudut yang dihitung
        let angle: CGFloat
        
        // Kalkulasi Sudut (Left)
        if sideToMeasure == .left {
            guard let leftHip = recognizedPoints[.leftHip],
                  let leftShoulder = recognizedPoints[.leftShoulder],
                  let leftWrist = recognizedPoints[.leftWrist],
                  leftHip.confidence > 0.1 && leftShoulder.confidence > 0.1 && leftWrist.confidence > 0.1 else {
                
                DispatchQueue.main.async { self.angleText = "Left shoulder in Position" }
                // Reset stabilitas jika pose tidak terdeteksi
                self.stabilityCounter = 0
                self.lastAngle = nil
                return
            }
            angle = calculateAngle(p1: leftHip.location, p2: leftShoulder.location, p3: leftWrist.location)
            
        // Kalkulasi Sudut (Right)
        } else {
            guard let rightHip = recognizedPoints[.rightHip],
                  let rightShoulder = recognizedPoints[.rightShoulder],
                  let rightWrist = recognizedPoints[.rightWrist],
                  rightHip.confidence > 0.1 && rightShoulder.confidence > 0.1 && rightWrist.confidence > 0.1 else {
                
                DispatchQueue.main.async { self.angleText = "Right shoulder in Position" }
                // Reset stabilitas jika pose tidak terdeteksi
                self.stabilityCounter = 0
                self.lastAngle = nil
                return
            }
            angle = calculateAngle(p1: rightHip.location, p2: rightShoulder.location, p3: rightWrist.location)
        }
        
        // --- LOGIC STABILITAS & TRIGGER BARU ---
        
        let roundedAngle = Int(angle)
        
        // 1. Update Teks Sudut di UI
        DispatchQueue.main.async {
            // Jangan update teks jika sudah capture (agar "Captured!" tetap terlihat)
            if !self.hasCaptured {
                self.angleText = "\(self.sideToMeasure == .left ? "Left" : "Right"): \(roundedAngle)°"
            }
        }

        // 2. Cek Stabilitas
        // Cek apakah sudut saat ini mirip dengan sudut frame sebelumnya
        // (toleransi 2.0 derajat)
        if abs(angle - (lastAngle ?? 0)) < 2.0 {
            stabilityCounter += 1 // Jika stabil, tambah counter
        } else {
            stabilityCounter = 0 // Jika tidak stabil (bergerak), reset counter
        }
        lastAngle = angle // Simpan sudut terakhir untuk perbandingan di frame berikutnya

        // 3. Cek Trigger Capture
        // Jika counter mencapai threshold (stabil cukup lama),
        // DAN kita belum pernah capture,
        // DAN sudutnya lebih dari 15 derajat (agar tidak capture saat tangan di bawah)
        if stabilityCounter > stabilityThreshold && !hasCaptured && angle > 15.0 {
            
            self.angleToCapture = roundedAngle
                self.jointsToCapture = self.detectedJoints
            
            self.currentStableAngle = roundedAngle // Simpan sudut saat ini untuk HistoryItem
            self.captureTriggered = true          // Aktifkan trigger untuk capture
            
            // Beri feedback ke user bahwa kita akan mengambil gambar
            DispatchQueue.main.async {
                self.angleText = "Hold it... \(roundedAngle)°"
            }
        }
        // --- AKHIR LOGIC STABILITAS ---
    }
    
    // Fungsi kalkulasi sudut (tidak berubah)
    private func calculateAngle(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let v1 = (x: p1.x - p2.x, y: p1.y - p2.y)
        let v2 = (x: p3.x - p2.x, y: p3.y - p2.y)
        
        let dotProduct = (v1.x * v2.x) + (v1.y * v2.y)
        let magV1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let magV2 = sqrt(v2.x * v2.x + v2.y * v2.y)
        
        guard magV1 != 0, magV2 != 0 else { return 0.0 }
        
        let cosTheta = dotProduct / (magV1 * magV2)
        // Clamp nilai untuk menghindari error acos (jika nilai sedikit di luar -1.0 s/d 1.0)
        let clampedCosTheta = max(-1.0, min(1.0, cosTheta))
        let angleRad = acos(clampedCosTheta)
        let angleDeg = angleRad * (180.0 / .pi)
        
        return angleDeg
    }
}
