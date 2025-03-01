import SwiftUI

struct ContentAnalysisView: View {
    @ObservedObject var viewModel: LearningViewModel
    @State private var showLearningPath = false
    @State private var showDeepQuestions = false
    @State private var showCrossRecommendations = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with topic and back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Text(viewModel.currentTopic)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Collection stats and progress
                if let collection = viewModel.contentCollection {
                    InformationStatusView(
                        title: "学习材料",
                        value: "\(collection.content.count)",
                        iconName: "doc.text.magnifyingglass",
                        color: .blue
                    )
                    
                    // Progress
                    if let currentGoal = viewModel.getCurrentGoal() {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("学习进度")
                                .font(.headline)
                            
                            HStack {
                                ProgressView(value: Double(currentGoal.progress) / 100.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                
                                Text("\(currentGoal.progress)%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Learning tools navigation buttons
                    HStack(spacing: 15) {
                        NavigationButton(
                            title: "学习路径",
                            iconName: "map",
                            color: .green,
                            action: { showLearningPath = true }
                        )
                        
                        NavigationButton(
                            title: "深度问题",
                            iconName: "questionmark.circle",
                            color: .orange,
                            action: { 
                                showDeepQuestions = true
                                viewModel.fetchDeepQuestions()
                            }
                        )
                        
                        NavigationButton(
                            title: "跨学科探索",
                            iconName: "arrow.triangle.branch",
                            color: .purple,
                            action: { 
                                showCrossRecommendations = true 
                                viewModel.fetchCrossDisciplinaryRecommendations()
                            }
                        )
                    }
                    
                    // Content list
                    VStack(alignment: .leading, spacing: 15) {
                        Text("内容收集")
                            .font(.headline)
                            .padding(.top, 5)
                        
                        ForEach(collection.content) { content in
                            ContentCardView(content: content, viewModel: viewModel)
                        }
                    }
                } else {
                    if viewModel.isLoading {
                        VStack(spacing: 20) {
                            ProgressView("加载内容中...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                            
                            // Helpful text
                            Text("我们正在为您分析与\(viewModel.currentTopic)相关的材料")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    } else {
                        Text("无可用内容。请尝试不同的主题或稍后再试。")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .padding()
            .navigationDestination(isPresented: $showLearningPath) {
                LearningPathView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showDeepQuestions) {
                DeepQuestionsView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showCrossRecommendations) {
                CrossDisciplinaryView(viewModel: viewModel)
            }
            .onAppear {
                if viewModel.contentCollection == nil {
                    viewModel.fetchContentForCurrentTopic()
                }
            }
        }
        .alert(isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Alert(
                title: Text("错误"),
                message: Text(viewModel.error ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
        .navigationBarHidden(true)
    }
}

// Helper Views

struct InformationStatusView: View {
    var title: String
    var value: String
    var iconName: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct NavigationButton: View {
    var title: String
    var iconName: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ContentCardView: View {
    var content: Content
    @ObservedObject var viewModel: LearningViewModel
    @State private var isRead = false
    @State private var isSaved = false
    @State private var isCompleted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and type badge
            HStack {
                Text(contentTypeName(content.type))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(contentTypeColor(content.type).opacity(0.2))
                    .foregroundColor(contentTypeColor(content.type))
                    .cornerRadius(4)
                
                Spacer()
                
                // Relevance score
                HStack {
                    Text("相关度:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(Double(i) / 5.0 <= content.relevanceScore ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            Text(content.title)
                .font(.headline)
            
            HStack(alignment: .top) {
                Text("作者:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(content.authors.joined(separator: ", "))
                    .font(.caption)
            }
            
            Text(content.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(content.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Interaction buttons
            HStack {
                Button(action: {
                    isRead = true
                    viewModel.recordActivity(
                        contentId: content.id,
                        action: .viewed
                    )
                }) {
                    Label("阅读", systemImage: isRead ? "book.fill" : "book")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isRead ? Color.green.opacity(0.3) : Color.green.opacity(0.2))
                        .foregroundColor(isRead ? .green : .primary)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: {
                    isCompleted.toggle()
                    viewModel.recordActivity(
                        contentId: content.id,
                        action: .completed
                    )
                }) {
                    Label("完成", systemImage: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isCompleted ? Color.purple.opacity(0.3) : Color.purple.opacity(0.2))
                        .foregroundColor(isCompleted ? .purple : .primary)
                        .cornerRadius(4)
                }
                
                Button(action: {
                    isSaved.toggle()
                    viewModel.recordActivity(
                        contentId: content.id,
                        action: .saved
                    )
                }) {
                    Label("保存", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSaved ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2))
                        .foregroundColor(isSaved ? .blue : .primary)
                        .cornerRadius(4)
                }
                
                Button(action: {
                    viewModel.recordActivity(
                        contentId: content.id,
                        action: .shared
                    )
                }) {
                    Label("分享", systemImage: "square.and.arrow.up")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Helper methods for content type display
    private func contentTypeName(_ type: Content.ContentType) -> String {
        switch type {
        case .academic:
            return "学术"
        case .news:
            return "新闻"
        case .synthetic:
            return "综合"
        case .userGenerated:
            return "用户创建"
        }
    }
    
    private func contentTypeColor(_ type: Content.ContentType) -> Color {
        switch type {
        case .academic:
            return .blue
        case .news:
            return .orange
        case .synthetic:
            return .purple
        case .userGenerated:
            return .green
        }
    }
}

struct ContentAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentAnalysisView(viewModel: LearningViewModel())
        }
    }
}
