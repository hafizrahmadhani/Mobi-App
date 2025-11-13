//
//  BackgroundModifier.swift
//  Mobi
//
//  Created by Hafiz Rahmadhani on 07/11/25.
//

import SwiftUI

struct BackgroundImageModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack {
            Color(hex: "F1F1F1")
                .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        self.modifier(BackgroundImageModifier())
    }
}
