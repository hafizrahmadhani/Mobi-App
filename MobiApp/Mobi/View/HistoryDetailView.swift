//
//  HistoryDetailView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 12/11/25.
//

import SwiftUI

struct HistoryDetailView: View {
    
    let item: HistoryItem
    
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var loadedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text(item.date, formatter: dateFormatter)
                    .foregroundStyle(.white)
                    .padding(.bottom)
                    
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
                .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fit)
                .clipped()
                .padding(.top, 8)
                
                Spacer()
                AngleOverlayView(angleText: "\(item.angle)°")
            }
        }
        .onAppear {
            if loadedImage == nil {
                self.loadedImage = historyViewModel.loadImage(fileName: item.imageFileName)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter
    }
}

#Preview {
    NavigationStack {
        let mockItem = HistoryItem(
            id: UUID(),
            date: Date(),
            side: .left,
            angle: 66,
            imageFileName: "example.jpg"
        )
        HistoryDetailView(item: mockItem)
            .environmentObject(HistoryViewModel())
    }
}
