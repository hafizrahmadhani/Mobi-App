//
//  HistoryCardView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 11/11/25.
//

import SwiftUI

struct HistoryCardView: View {
    
    let item: HistoryItem
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var loadedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
            }
            .aspectRatio(3/4, contentMode: .fill)
            .clipped()
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundStyle(.white)
                
                Text(item.side == .left ? "Left Shoulder" : "Right Shoulder")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(Image(systemName: "angle"))\(item.angle)°")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#F15E32"))
        }
        .cornerRadius(12)
        .onAppear {
            if loadedImage == nil {
                self.loadedImage = historyViewModel.loadImage(fileName: item.imageFileName)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }
}

#Preview {
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
        .environmentObject(HistoryViewModel())
}
