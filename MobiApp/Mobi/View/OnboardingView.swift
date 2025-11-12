//
//  OnboardingView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    private var description1: Text {
        var part1 = AttributedString("Understanding your ")
        part1.font = .subheadline
        part1.foregroundColor = Color(hex: "#3C3C43").opacity(0.6)
        
        var part2 = AttributedString("true")
        part2.font = .subheadline.italic().weight(.bold)
        part2.foregroundColor = Color(hex: "#F15E32")
        
        var part3 = AttributedString(" shoulder mobility is the first step to moving freely again.")
        part3.font = .subheadline
        part3.foregroundColor = Color(hex: "#3C3C43").opacity(0.6)
        
        let finalString = part1 + part2 + part3
        
        return Text(finalString)
    }
    
    private func defaultDescription(_ text: String) -> Text {
        var finalString = AttributedString(text)
        finalString.font = .subheadline
        finalString.foregroundColor = Color(hex: "#3C3C43").opacity(0.6)
        return Text(finalString)
    }
    
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
                    description: description1
                )
                
                OnboardingItemView(
                    iconName: "angle",
                    title: "Measure, Don't Guess",
                    description: defaultDescription("Get an accurate measurement of your shoulder's range of motion, displayed clearly in degrees (°).")
                )
                
                OnboardingItemView(
                    iconName: "chart.line.uptrend.xyaxis",
                    title: "Track the Progress",
                    description: defaultDescription("See your progress over time by checking your measurement history.")
                )
                
                OnboardingItemView(
                    iconName: "figure.mixed.cardio",
                    title: "Ready to Move Better?",
                    description: defaultDescription("Let’s take your first measurement and start your journey.")
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
    let description: Text
    
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
                
                description
            }
        }
    }
}

#Preview {
    OnboardingView()
}
