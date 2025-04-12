import SwiftUI

struct LoggedDreamView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var dreamText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $dreamText)
                .frame(height: 200)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button("Save") {
                viewModel.addDream(text: dreamText)
                viewModel.showPopup = false
            }
            .disabled(dreamText.isEmpty)
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}