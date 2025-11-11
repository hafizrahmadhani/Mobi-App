//
//  GlassButtonView.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI

struct GlassButtonView: View {
    var text: String
    var backgroundColor: Color = Color.customOrange
    var foregroundColor: Color = .white
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(foregroundColor)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    backgroundColor
                )
                .background(
                    .ultraThinMaterial
                )
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PressableScaleStyle())
    }
}

struct PressableScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
