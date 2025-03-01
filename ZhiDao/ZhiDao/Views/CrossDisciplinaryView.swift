import SwiftUI

struct CrossDisciplinaryView: View {
    @ObservedObject var viewModel: LearningViewModel
    @State private var selectedRec: CrossDisciplinaryRecommendation?
    @State private var showingDetail = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("跨学科探索")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("通过探索相关领域扩展你的知识")
                    .foregroundColor(.secondary)
                
                // Current topic context
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前主题:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.currentTopic)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Recommendations
                if viewModel.crossDisciplinaryRecommendations.isEmpty {
                    if viewModel.isLoading {
                        ProgressView("加载推荐中...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        Text("无可用的跨学科推荐。请尝试不同的主题。")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    Text("探索这些相关领域")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(viewModel.crossDisciplinaryRecommendations) { rec in
                        Button(action: {
                            selectedRec = rec
                            showingDetail = true
                        }) {
                            RecommendationCardView(recommendation: rec)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
            .navigationTitle("跨学科探索")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDetail) {
                if let recommendation = selectedRec {
                    RecommendationDetailView(recommendation: recommendation, viewModel: viewModel)
                }
            }
            .alert(isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Alert(
                    title: Text("错误"),
                    message: Text(viewModel.error ?? "发生未知错误"),
                    dismissButton: .default(Text("确定"))
                )
            }
            .onAppear {
                if viewModel.crossDisciplinaryRecommendations.isEmpty {
                    viewModel.fetchCrossDisciplinaryRecommendations()
                }
            }
        }
    }
}

struct RecommendationCardView: View {
    var recommendation: CrossDisciplinaryRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Discipline badge
                Text(recommendation.area)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(fieldColor(recommendation.area).opacity(0.2))
                    .foregroundColor(fieldColor(recommendation.area))
                    .cornerRadius(4)
                
                Spacer()
                
                // Relevance indicator
                HStack(spacing: 2) {
                    Text("相关度:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(i <= recommendation.explorationDifficulty ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            Text(recommendation.area)
                .font(.headline)
                .lineLimit(2)
            
            Text(recommendation.connection)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Spacer()
                
                Text("查看更多")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func fieldColor(_ field: String) -> Color {
        switch field.lowercased() {
        case "物理学", "physics":
            return .blue
        case "心理学", "psychology":
            return .purple
        case "历史", "history":
            return .brown
        case "艺术", "art":
            return .pink
        case "生物学", "biology":
            return .green
        case "哲学", "philosophy":
            return .orange
        case "数学", "mathematics":
            return .red
        default:
            return .teal
        }
    }
}

struct RecommendationDetailView: View {
    var recommendation: CrossDisciplinaryRecommendation
    @ObservedObject var viewModel: LearningViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Field and relevance
                HStack {
                    Text(recommendation.area)
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(fieldColor(recommendation.area).opacity(0.2))
                        .foregroundColor(fieldColor(recommendation.area))
                        .cornerRadius(5)
                    
                    Spacer()
                    
                    HStack {
                        Text("相关度:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(1...recommendation.explorationDifficulty, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        ForEach(recommendation.explorationDifficulty..<5, id: \.self) { _ in
                            Image(systemName: "star")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top)
                
                // Title
                Text(recommendation.area)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Description
                Text(recommendation.valueProposition)
                    .font(.body)
                
                Divider()
                    .padding(.vertical, 5)
                
                // Connection to main topic
                VStack(alignment: .leading, spacing: 10) {
                    Text("与主题的联系")
                        .font(.headline)
                    
                    Text(recommendation.connection)
                }
                
                Divider()
                    .padding(.vertical, 5)
                
                // Action buttons
                HStack {
                    Button(action: {
                        viewModel.switchTopic(to: recommendation.area)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label(
                            title: { Text("探索这个主题") },
                            icon: { Image(systemName: "arrow.right.circle.fill") }
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(fieldColor(recommendation.area))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("跨学科探索")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func fieldColor(_ field: String) -> Color {
        switch field.lowercased() {
        case "物理学", "physics":
            return .blue
        case "心理学", "psychology":
            return .purple
        case "历史", "history":
            return .brown
        case "艺术", "art":
            return .pink
        case "生物学", "biology":
            return .green
        case "哲学", "philosophy":
            return .orange
        case "数学", "mathematics":
            return .red
        default:
            return .teal
        }
    }
}

struct CrossDisciplinaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CrossDisciplinaryView(viewModel: LearningViewModel())
        }
    }
}
