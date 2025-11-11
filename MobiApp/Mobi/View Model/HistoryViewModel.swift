//
//  HistoryViewModel.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import Foundation
import SwiftUI
import Combine

class HistoryViewModel: ObservableObject {
    
    @Published var historyItems: [HistoryItem] = []
    
    // URL untuk menyimpan data
    private var historyURL: URL
    private var imagesDirectoryURL: URL
    
    init() {
        // Tentukan lokasi folder Documents
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access Documents folder.")
        }
        
        // 1. Tentukan path untuk file JSON
        self.historyURL = documentsDirectory.appendingPathComponent("history.json")
        
        // 2. Tentukan path untuk folder gambar
        self.imagesDirectoryURL = documentsDirectory.appendingPathComponent("HistoryImages")
        
        // 3. Buat folder gambar jika belum ada
        if !fileManager.fileExists(atPath: imagesDirectoryURL.path) {
            try? fileManager.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 4. Muat data saat app dibuka
        loadHistory()
        
        // loadMockData() // Hapus atau jadikan komentar
    }
    
    // --- FUNGSI BARU UNTUK MENYIMPAN ---
    
    // Fungsi ini dipanggil dari PoseMeasurementView
    func addHistory(image: UIImage, side: ShoulderSide, angle: Int) {
        
        // 1. Buat nama file unik untuk gambar
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        
        // 2. Ubah UIImage ke data JPEG
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return
        }
        
        // 3. Tulis data gambar ke file
        do {
            try data.write(to: fileURL)
            
            // 4. Buat HistoryItem baru dengan nama file
            let newItem = HistoryItem(
                id: UUID(),
                date: Date(),
                side: side,
                angle: angle,
                imageFileName: fileName
            )
            
            // 5. Tambahkan ke array & simpan
            DispatchQueue.main.async {
                self.historyItems.insert(newItem, at: 0)
                self.saveHistory()
            }
            
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    // --- FUNGSI HELPER UNTUK SAVE/LOAD ---
    
    private func saveHistory() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Format tanggal yang standar
        
        do {
            let data = try encoder.encode(historyItems)
            try data.write(to: historyURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save history.json: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = try? Data(contentsOf: historyURL) else {
            print("History.json file not found. Starting with empty data.")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let items = try decoder.decode([HistoryItem].self, from: data)
            self.historyItems = items
        } catch {
            print("Failed to decode history.json: \(error)")
        }
    }
    
    // --- FUNGSI HELPER UNTUK CARD VIEW ---
    
    // Fungsi ini akan dipanggil oleh HistoryCardView
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else {
            print("Failed to load image \(fileName)")
            return nil
        }
        return UIImage(data: data)
    }
    
    // ... (Hapus fungsi loadMockData() atau sesuaikan) ...
}
