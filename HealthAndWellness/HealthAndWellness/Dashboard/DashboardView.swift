//
//  DashboardView.swift
//  HealthAndWellness
//
//  Created by Sengi Mathias on 4/12/25.
//

import SwiftUI

struct DashboardView: View {
    var width = UIScreen.main.bounds.width
    @StateObject var viewModel = DashboardViewModel()
    var body: some View {
        ZStack(){
            Color.comet
                .ignoresSafeArea()
            ScrollView{
                ZStack{
                    Rectangle()
                        .fill(Color.midPurple)
                        .cornerRadius(25)
                        .frame(width: width-50, height: 100)
                    VStack{
                        Text("Enter a dream?")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        Button {
                            viewModel.logDreamBool = true
                        } label: {
                            ZStack{
                                Rectangle()
                                    .fill(Color.GunPowder)
                                    .frame(width: width-200, height: 50)
                                    .cornerRadius(10.0)
                                Text("Log Dream")
                                    .foregroundColor(Color.white)
                            }
                                
                        }

                        
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.showPopup) {
                LoggedDream_( viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.logDreamBool) {
                LogDream()
            }
        }
        
    }
}

#Preview {
    DashboardView()
}
