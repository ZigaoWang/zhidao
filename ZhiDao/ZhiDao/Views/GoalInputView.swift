import SwiftUI

struct GoalInputView: View {
    @ObservedObject var viewModel: LearningViewModel
    @State private var goalText: String = ""
    @State private var timeframe: String = "1月"
    @State private var selectedPriority: LearningGoal.GoalPriority = .medium
    @State private var showMainContent = false
    
    // Available timeframes
    private let timeframes = ["1周", "1月", "3月", "6月", "1年"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("你想学习什么？")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("输入你感兴趣的学习目标或主题")
                .foregroundColor(.secondary)
            
            // Goal Text Input
            TextField("例如：机器学习基础，量子计算...", text: $goalText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .disableAutocorrection(true)
            
            // Timeframe Picker
            VStack(alignment: .leading) {
                Text("你想花多长时间学习？")
                    .font(.headline)
                
                Picker("时间范围", selection: $timeframe) {
                    ForEach(timeframes, id: \.self) { timeframe in
                        Text(timeframe).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Priority Picker
            VStack(alignment: .leading) {
                Text("优先级")
                    .font(.headline)
                
                Picker("优先级", selection: $selectedPriority) {
                    Text("低").tag(LearningGoal.GoalPriority.low)
                    Text("中").tag(LearningGoal.GoalPriority.medium)
                    Text("高").tag(LearningGoal.GoalPriority.high)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Spacer()
            
            // Submit Button
            Button(action: {
                guard !goalText.isEmpty else { return }
                
                // Create the learning goal
                viewModel.createLearningGoal(
                    goal: goalText,
                    timeframe: timeframe,
                    priority: selectedPriority
                )
                
                // Navigate to the main content
                showMainContent = true
            }) {
                Text("开始学习")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(goalText.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(goalText.isEmpty)
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("设置学习目标")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showMainContent) {
            ContentAnalysisView(viewModel: viewModel)
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView("处理中...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        )
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Alert(
                title: Text("错误"),
                message: Text(viewModel.error ?? "发生未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}

struct GoalInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GoalInputView(viewModel: LearningViewModel())
        }
    }
}
