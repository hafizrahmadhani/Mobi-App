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
    
    var body: some Scene {
        WindowGroup {
            if splashScreen {
                SplashScreenView(isFirst: $splashScreen)
            }else {
                NavigationStack {
                    if hasSeenOnboarding {
                        MainPageView()
                    } else {
                        AuthorizationPageView()
                    }
                }
            }
        }
    }
}
