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
    private var historyURL: URL
    private var imagesDirectoryURL: URL
    
    init() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access Documents folder.")
        }
        
        self.historyURL = documentsDirectory.appendingPathComponent("history.json")
        self.imagesDirectoryURL = documentsDirectory.appendingPathComponent("HistoryImages")
        
        if !fileManager.fileExists(atPath: imagesDirectoryURL.path) {
            try? fileManager.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        loadHistory()
        
    }
    
    func addHistory(image: UIImage, side: ShoulderSide, angle: Int) {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return
        }
        
        do {
            try data.write(to: fileURL)
            let newItem = HistoryItem(
                id: UUID(),
                date: Date(),
                side: side,
                angle: angle,
                imageFileName: fileName
            )
            
            DispatchQueue.main.async {
                self.historyItems.insert(newItem, at: 0)
                self.saveHistory()
            }
            
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    private func saveHistory() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
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
    
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else {
            print("Failed to load image \(fileName)")
            return nil
        }
        return UIImage(data: data)
    }
}
