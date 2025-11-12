//
//  HistoryItem.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import SwiftUI
import Foundation

struct HistoryItem: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let side: ShoulderSide
    let angle: Int
    let imageFileName: String
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.id == rhs.id
    }
}
