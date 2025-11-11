//
//  AngleOverlayView.swift
//  Mobi
//
//  Created by Muhammad Al Hafiz Rahmadhani on 05/11/25.
//

import SwiftUI

struct AngleOverlayView: View {
    
    let angleText: String
    
    var body: some View {
        Text(angleText)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .padding(12)
            .background(Color(hex: "#F15E32")).opacity(1)
            .cornerRadius(10)
            .padding(.bottom, 30)
    }
}

struct AngleOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        AngleOverlayView(angleText: "Contoh: 180°")
            .background(Color.gray)
    }
}
