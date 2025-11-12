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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
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
                    .padding(.top, 16)
                
            }
            .padding(.horizontal)
            //.zIndex(1)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Your journey to better movement starts here.")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "#3C3C43")).opacity(0.6)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
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
                        VStack(spacing: 8) {
                            Text("No history yet.")
                                .font(.headline)
                                .foregroundStyle(Color(hex: "#3C3C43")).opacity(0.6)
                            Text("Start a new measurement to see your progress.")
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "#3C3C43")).opacity(0.6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        
                    } else {
                        let columns = [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(historyViewModel.historyItems) { item in
                                NavigationLink(value: item) {
                                    HistoryCardView(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
        }
        .navigationDestination(item: $selectedSide) { side in
            PoseMeasurementView(side: side)
        }
        .navigationDestination(for: HistoryItem.self) { item in
            HistoryDetailView(item: item)
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

