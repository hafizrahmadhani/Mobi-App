//
//  SplashScreenView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isFirst : Bool
    
    var body: some View {
        Image("MobiIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        self.isFirst = false
                    }
                }
            }
            .ignoresSafeArea()
            .appBackground()
    }
}

#Preview {
    SplashScreenView(isFirst: .constant(true))
}
