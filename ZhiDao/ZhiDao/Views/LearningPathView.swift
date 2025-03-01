import SwiftUI

struct LearningPathView: View {
    @ObservedObject var viewModel: LearningViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header with back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Text("您的学习路径")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                Text("这个个性化路径将帮助您实现学习目标：")
                    .foregroundColor(.secondary)
                
                Text(viewModel.currentTopic)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                if let path = viewModel.learningPath {
                    // Foundational concepts
                    LearningPathSectionView(
                        title: "基础概念",
                        description: "从这些核心概念开始",
                        items: path.foundational,
                        iconName: "1.circle.fill",
                        color: .blue,
                        viewModel: viewModel
                    )
                    
                    // Intermediate topics
                    LearningPathSectionView(
                        title: "构建知识",
                        description: "通过这些主题深化理解",
                        items: path.intermediate,
                        iconName: "2.circle.fill",
                        color: .green,
                        viewModel: viewModel
                    )
                    
                    // Advanced concepts
                    LearningPathSectionView(
                        title: "高级概念",
                        description: "挑战自我，拓展思维",
                        items: path.advanced,
                        iconName: "3.circle.fill",
                        color: .orange,
                        viewModel: viewModel
                    )
                    
                    // Projects and applications
                    LearningPathSectionView(
                        title: "项目与应用",
                        description: "通过实践巩固所学知识",
                        items: path.projects,
                        iconName: "4.circle.fill",
                        color: .purple,
                        viewModel: viewModel
                    )
                } else {
                    // Loading state
                    ProgressView("正在生成您的学习路径...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 50)
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.learningPath == nil {
                viewModel.fetchLearningPath()
            }
        }
    }
}

struct LearningPathSectionView: View {
    var title: String
    var description: String
    var items: [String]
    var iconName: String
    var color: Color
    var viewModel: LearningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .cornerRadius(18)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Items list
            VStack(alignment: .leading, spacing: 8) {
                if !items.isEmpty {
                    // First item
                    ItemRowView(item: items[0], color: color, viewModel: viewModel)
                    
                    if items.count > 1 {
                        Divider()
                        // Second item
                        ItemRowView(item: items[1], color: color, viewModel: viewModel)
                    }
                    
                    if items.count > 2 {
                        Divider()
                        // Third item
                        ItemRowView(item: items[2], color: color, viewModel: viewModel)
                    }
                    
                    if items.count > 3 {
                        Divider()
                        // Fourth item
                        ItemRowView(item: items[3], color: color, viewModel: viewModel)
                    }
                    
                    if items.count > 4 {
                        Divider()
                        // Fifth item
                        ItemRowView(item: items[4], color: color, viewModel: viewModel)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct ItemRowView: View {
    var item: String
    var color: Color
    var viewModel: LearningViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark.circle")
                .foregroundColor(color.opacity(0.8))
                .padding(.top, 2)
            
            Text(item)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: {
                viewModel.recordLearningPathInteraction(item: item)
            }) {
                Image(systemName: "bookmark")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

struct LearningPathView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LearningViewModel()
        let samplePath = LearningPath(
            foundational: ["Basic Concept 1", "Basic Concept 2"],
            intermediate: ["Intermediate Topic 1", "Intermediate Topic 2"],
            advanced: ["Advanced Area 1", "Advanced Area 2"],
            projects: ["Project Idea 1", "Project Idea 2"]
        )
        
        NavigationView {
            LearningPathView(viewModel: viewModel)
        }
    }
}
