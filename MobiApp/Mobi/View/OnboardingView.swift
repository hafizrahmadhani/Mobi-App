//
//  OnboardingView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack() {
            Text("Getting Started in Mobi")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.bottom, 40)
                .padding(.horizontal, 30)
            
            VStack(alignment: .leading, spacing: 28) {
                OnboardingItemView(
                    iconName: "figure.cooldown",
                    title: "Feeling Stiff or Recovering?",
                    description: "Understanding your *true* shoulder mobility is the first step to moving freely again."
                )
                
                OnboardingItemView(
                    iconName: "angle",
                    title: "Measure, Don't Guess",
                    description: "Get an accurate measurement of your shoulder's range of motion, displayed clearly in degrees (°)."
                )
                
                OnboardingItemView(
                    iconName: "chart.line.uptrend.xyaxis",
                    title: "Monitor Your Improvements",
                    description: "See your progress over time by checking your measurement history."
                )
                
                OnboardingItemView(
                    iconName: "figure.mixed.cardio",
                    title: "Ready to Move Better?",
                    description: "Let’s take your first measurement and start your journey."
                )
                
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            GlassButtonView(
                text: "Continue",
                foregroundColor: .white,
                action: {
                    dismiss()
                }
            )
            .frame(width: 330, height: 48)
            .padding(.bottom, 30)
        }
        .appBackground()
    }
}

struct OnboardingItemView: View {
    let iconName: String
    let title: String
    let description: LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: iconName)
                .font(.title)
                .frame(width: 35)
                .foregroundStyle(Color(hex: "#F15E32"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#3C3C43")).opacity(0.6)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
