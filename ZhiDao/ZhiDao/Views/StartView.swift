import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = LearningViewModel()
    @State private var showGoalInput = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // App Logo
                Image(systemName: "lightbulb.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.yellow)
                    .padding(.top, 60)
                
                // Welcome Text
                Text("知道")
                    .font(.system(size: 42, weight: .bold))
                
                Text("AI驱动的持续学习助手")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Start Button
                Button(action: {
                    // Create a temporary user if none exists
                    if viewModel.currentUser == nil {
                        viewModel.createTemporaryUser()
                    }
                    showGoalInput = true
                }) {
                    Text("开始使用")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationDestination(isPresented: $showGoalInput) {
                GoalInputView(viewModel: viewModel)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
