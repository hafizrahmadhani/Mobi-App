//
//  HistoryItem.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import SwiftUI
import Foundation

// Model untuk setiap item di History
struct HistoryItem: Identifiable, Hashable, Codable {
    let id: UUID // Ganti dari 'let id = UUID()'
    let date: Date
    let side: ShoulderSide
    let angle: Int
    let imageFileName: String
    
    // Kita juga butuh Equatable
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.id == rhs.id
    }
}
