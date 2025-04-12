//
//  ContentView.swift
//  HealthAndWellness
//
//  Created by Sengi Mathias on 4/12/25.
//

import SwiftUI

struct TitleView: View {
    @State var isPlaying: Bool = false
    var body: some View {
        if isPlaying {
            DashboardView()
        } else {
            ZStack{
                Color.comet
                    .ignoresSafeArea() // Fills entire screen
                VStack {
                    Spacer()
                    Text("REMind")
                        .foregroundStyle(Color.gold)
                        .font(.system(size: 80))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    ZStack{
                        Button(action: {
                            isPlaying = true
                        }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color.GunPowder)
                        }
                        
                    }
                    
                    Spacer()
                }
                .padding()
                
            }
        }
    }
}

#Preview {
    TitleView()
}
