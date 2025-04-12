//
//  DashboardView.swift
//  HealthAndWellness
//
//  Created by Sengi Mathias on 4/12/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    var body: some View {
        ZStack{
            Color.comet
                .ignoresSafeArea()
            LazyVStack{
                
            }
        }
        .fullScreenCover(isPresented: $viewModel.showPopup) {
            LoggedDream_( viewModel: viewModel)
        }
    }
    
}

#Preview {
    DashboardView()
}
