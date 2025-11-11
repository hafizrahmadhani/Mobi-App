//
//  MainPageView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI

struct MainPageView: View {
    
    @State private var selectedSide: ShoulderSide?
    @EnvironmentObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome to Mobi")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "2C7FCF"), Color(hex: "F15E32")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.top)
                .padding(.horizontal)
            
            Text("Your journey to better movement starts here.")
                .font(.headline)
                .foregroundStyle(Color(hex: "#3C3C43")).opacity(0.6)
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            
            HStack(spacing: 10) {
                VStack(spacing: 20){
                    Text("Left Shoulder")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Image("LeftShoulder")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 105)
                    GlassButtonView(
                        text: "Begin",
                        action: {
                            selectedSide = .left
                            
                        })
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                
                VStack(spacing: 20){
                    Text("Right Shoulder")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                    
                    Image("RightShoulder")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 105)
                    GlassButtonView(
                        text: "Begin",
                        action: {
                            selectedSide = .right
                            
                        })
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            }
            .padding(.horizontal)
            
            Text("History")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if historyViewModel.historyItems.isEmpty {
                VStack {
                    Spacer()
                    Text("No history yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Start a new measurement to see your progress.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Isi sisa space
                
            } else {
                
                // --- KODE GRID HANYA JIKA TIDAK KOSONG ---
                
                let columns = [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ]
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(historyViewModel.historyItems) { item in
                            HistoryCardView(item: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationDestination(item: $selectedSide) { side in
            PoseMeasurementView(side: side)
        }
        .navigationBarBackButtonHidden(true)
        .appBackground()
        
    }
}

#Preview {
    NavigationStack {
        MainPageView()
            .environmentObject(HistoryViewModel())
    }
}
