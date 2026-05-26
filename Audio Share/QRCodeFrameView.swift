//
//  QRCodeFrameView.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/19/24.
//

import SwiftUI

struct QRCodeFrameView: View {
    var qrCodeFrame: CGRect

    var body: some View {
        GeometryReader { geometry in
            if qrCodeFrame != .zero {
                Path { path in
                    path.addRect(qrCodeFrame)
                }
                .stroke(Color.yellow, lineWidth: 2)
                .position(x: qrCodeFrame.midX, y: qrCodeFrame.midY)
            }
        }
    }
}
