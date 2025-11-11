//
//  MobiApp.swift
//  Mobi
//
//  Created by Muhammad Al Hafiz Rahmadhani on 05/11/25.
//

import SwiftUI

@main
struct MobiApp: App {
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    @State private var splashScreen = true
    @StateObject private var historyViewModel = HistoryViewModel()
    
    var body: some Scene {
        WindowGroup {
            // --- MULAI PERBAIKAN ---
            
            // 1. Bungkus semua logika di dalam Group
            Group {
                if splashScreen {
                    SplashScreenView(isFirst: $splashScreen)
                } else {
                    NavigationStack {
                        if hasSeenOnboarding {
                            MainPageView()
                        } else {
                            AuthorizationPageView()
                        }
                    }
                }
            }
            // 2. Terapkan environmentObject ke Group
            .environmentObject(historyViewModel)
            
            // --- AKHIR PERBAIKAN ---
        }
    }
}
