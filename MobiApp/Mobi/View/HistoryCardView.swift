//
//  HistoryCardView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import SwiftUI

struct HistoryCardView: View {
    let item: HistoryItem
    
    // 1. Dapatkan akses ke ViewModel
    @EnvironmentObject var historyViewModel: HistoryViewModel
    
    // 2. State untuk menampung gambar yg di-load
    @State private var loadedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- BAGIAN GAMBAR (BARU) ---
            Group {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    // Placeholder saat loading
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
            }
            .aspectRatio(3/4, contentMode: .fill) // <-- Rasio 3:4
            .clipped()
            
            // --- BAGIAN TEKS (WAJIB GANTI) ---
            VStack(alignment: .leading, spacing: 3) { // <-- Spacing kecil
                
                // 1. Teks Tanggal (INI AKAN MUNCUL)
                Text(item.date, formatter: dateFormatter)
                    .font(.caption) // <-- Font kecil
                    .foregroundColor(.white.opacity(0.8))
                
                // 2. Teks Sisi (Shoulder)
                Text(item.side == .left ? "Left Shoulder" : "Right Shoulder")
                    .font(.headline) // <-- Font besar
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 3. Teks Sudut
                (Text(Image(systemName: "angle")) + Text(" \(item.angle)°"))
                    .font(.subheadline) // <-- Font sedang
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#F15E32"))
        }
        .cornerRadius(12)
        .shadow(radius: 5)
        .onAppear {
            // 3. Muat gambar saat card muncul
            if loadedImage == nil { // Hindari loading ulang
                self.loadedImage = historyViewModel.loadImage(fileName: item.imageFileName)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
}

// Preview (perlu di-update agar tidak error)
#Preview {
    // Kita tidak bisa load image di preview, jadi kita beri contoh
    let mockItem = HistoryItem(
        id: UUID(),
        date: Date(),
        side: .left,
        angle: 30,
        imageFileName: "example.jpg"
    )
    
    return HistoryCardView(item: mockItem)
        .padding()
        .background(Color.gray)
        .frame(width: 180)
        .environmentObject(HistoryViewModel()) // <-- Tambahkan ini
}
