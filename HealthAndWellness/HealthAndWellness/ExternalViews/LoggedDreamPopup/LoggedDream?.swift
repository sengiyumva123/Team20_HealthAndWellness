//
//  LoggedDream?.swift
//  HealthAndWellness
//
//  Created by Sengi Mathias on 4/12/25.
//

import SwiftUI

struct LoggedDream_: View {
   @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        ZStack{
            Color.comet
                .ignoresSafeArea() 
            VStack {
                Spacer()
                Text("Have you entered a dream today?")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gold)
                    .font(.system(size: 80))
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                HStack{
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.showPopup = false
                        }
                    }) {
                        ZStack{
                        
                            Rectangle()
                                .cornerRadius(100)
                                .frame(width: 150, height: 80)
                                .foregroundColor(Color.GunPowder)
                            Text("Yes")
                                .foregroundColor(Color.gold)
                                .font(.title)
                        }
                    }
                    Button(action: {
                        viewModel.showPopup = false;
                        
                    }) {
                        ZStack{
                            Rectangle()
                                .cornerRadius(100)
                                .frame(width: 150, height: 80)
                                .foregroundColor(Color.GunPowder)
                            Text("No")
                                .foregroundColor(Color.gold)
                                .font(.title)
                        }
                    }
                    
                }
                
                Spacer()
            }
            .padding()
            
        }
    }
}

#Preview {
    LoggedDream_( viewModel: DashboardViewModel())
}
