//
//  AuthorizationPageView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI
import AVFoundation

struct AuthorizationPageView: View {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboardingModal = false
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Unlock Your Full Potential!")
                .font(.largeTitle)
                .bold()
            Text("To enjoy Mobi's feature and a seamless experience, please grant camera access. This allows us to accurately measure the results.")
                .foregroundStyle(Color(hex: "#3C3C43"))
                .opacity(0.6)
                .padding(.bottom)
            
            HStack(alignment: .top){
                Image("CameraIcon")
                    .resizable()
                    .frame(width: 44, height: 43)
                    .padding(.trailing)
                
                VStack{
                    Text("Enable camera access")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("To measure your arm’s angle accurately, we need to use your camera.").font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color(hex: "#3C3C43")).opacity(0.6)
                }
            }
            
            Spacer()
            
            GlassButtonView(text: "Turn On") {
                requestCameraPermission()
                hasSeenOnboarding = true
            }
            
            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("Later")
                    .font(.headline)
                    .underline()
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .padding(.top, 10)
            
        }
        .padding(.horizontal, 20)
        .padding(.top)
        .navigationBarBackButtonHidden(true)
        .appBackground()
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showOnboardingModal = true
            }
        }
        .sheet(isPresented: $showOnboardingModal) {
            OnboardingView()
                .interactiveDismissDisabled()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera permission granted: \(granted)")
        }
    }
}

#Preview {
    NavigationStack {
        AuthorizationPageView()
    }
}
