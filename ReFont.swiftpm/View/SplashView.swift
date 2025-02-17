//
//  SplashView.swift
//  ReFont
//
//  Created by 최희진 on 2/15/25.
//

import SwiftUI

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("ReFont")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .animation(.easeOut(duration: 1.2), value: isAnimating)
            }
        }
        .background(Color.white)
        .onAppear {
            isAnimating = true
        }
    }
}
