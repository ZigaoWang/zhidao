import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: LearningViewModel
    @State private var showAddGoal = false
    @State private var selectedProject: LearningGoal? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("您的学习项目")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            if let user = viewModel.currentUser {
                                Text("欢迎回来，\(user.name)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Profile icon
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Current Projects Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("进行中的项目")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showAddGoal = true
                            }) {
                                Label("添加", systemImage: "plus")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let goals = viewModel.currentUser?.learningGoals, !goals.isEmpty {
                            ForEach(goals) { goal in
                                ProjectCardView(goal: goal)
                                    .onTapGesture {
                                        viewModel.switchTopic(to: goal.goal)
                                        selectedProject = goal
                                    }
                            }
                        } else {
                            // Empty state
                            VStack(spacing: 15) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                                
                                Text("您还没有学习项目")
                                    .font(.headline)
                                
                                Text("点击\"添加\"开始您的学习之旅")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    showAddGoal = true
                                }) {
                                    Text("创建新项目")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                    
                    // Recent Activity Section
                    if let activities = viewModel.currentUser?.learningHistory, !activities.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("最近活动")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(activities.prefix(3)) { activity in
                                ActivityItemView(activity: activity)
                            }
                            
                            Button(action: {
                                // View all activities
                            }) {
                                Text("查看全部")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 5)
                        }
                    }
                    
                    // Recommended Projects
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推荐项目")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(getRecommendedProjects()) { project in
                                    RecommendedProjectCard(project: project)
                                        .onTapGesture {
                                            // Create this project
                                            viewModel.createLearningGoal(
                                                goal: project.title,
                                                timeframe: "1月",
                                                priority: .medium
                                            )
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationDestination(isPresented: $showAddGoal) {
                GoalInputView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedProject) { goal in
                ContentAnalysisView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
            .onAppear {
                // Create a temporary user if none exists
                if viewModel.currentUser == nil {
                    viewModel.createTemporaryUser()
                    
                    // Add sample projects for first launch
                    if viewModel.currentUser?.learningGoals.isEmpty ?? true {
                        viewModel.createSampleProjects()
                    }
                }
            }
        }
    }
    
    // Sample recommended projects
    private func getRecommendedProjects() -> [RecommendedProject] {
        return [
            RecommendedProject(id: "1", title: "人工智能基础", description: "了解AI的基本概念和应用", category: "技术", difficulty: 2),
            RecommendedProject(id: "2", title: "量子计算入门", description: "探索量子计算的原理和前景", category: "科学", difficulty: 4),
            RecommendedProject(id: "3", title: "中国古代哲学", description: "儒家、道家思想的发展与影响", category: "哲学", difficulty: 3),
            RecommendedProject(id: "4", title: "宏观经济学", description: "理解GDP、通货膨胀和经济周期", category: "经济", difficulty: 3)
        ]
    }
}

// Project Card Component
struct ProjectCardView: View {
    var goal: LearningGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Priority indicator
                Circle()
                    .fill(priorityColor)
                    .frame(width: 12, height: 12)
                
                Text(goal.goal)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Priority label
                Text(priorityText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                // Progress percentage and timeframe
                HStack {
                    Text("\(goal.progress)% 完成")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("目标: \(goal.timeframe)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Actual progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: max(geo.size.width * CGFloat(goal.progress) / 100, 8), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            
            // Topics
            if !goal.relatedTopics.isEmpty {
                HStack {
                    ForEach(goal.relatedTopics.prefix(3), id: \.self) { topic in
                        Text(topic)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if goal.relatedTopics.count > 3 {
                        Text("+\(goal.relatedTopics.count - 3)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // Helper properties for priority styling
    private var priorityColor: Color {
        switch goal.priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    private var priorityText: String {
        switch goal.priority {
        case .low:
            return "低优先级"
        case .medium:
            return "中优先级"
        case .high:
            return "高优先级"
        }
    }
    
    private var progressColor: Color {
        if goal.progress < 30 {
            return .red
        } else if goal.progress < 70 {
            return .orange
        } else {
            return .green
        }
    }
}

// Activity Item Component
struct ActivityItemView: View {
    var activity: LearningActivity
    
    var body: some View {
        HStack(spacing: 15) {
            // Activity icon
            Circle()
                .fill(activityColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: activityIcon)
                        .foregroundColor(activityColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatTimestamp(activity.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // Helper properties for activity styling
    private var activityIcon: String {
        switch activity.action {
        case .viewed:
            return "eye.fill"
        case .completed:
            return "checkmark.circle.fill"
        case .saved:
            return "bookmark.fill"
        case .shared:
            return "square.and.arrow.up.fill"
        }
    }
    
    private var activityColor: Color {
        switch activity.action {
        case .viewed:
            return .blue
        case .completed:
            return .green
        case .saved:
            return .purple
        case .shared:
            return .orange
        }
    }
    
    private var activityTitle: String {
        switch activity.action {
        case .viewed:
            return "查看了内容 ID: \(activity.contentId)"
        case .completed:
            return "完成了内容 ID: \(activity.contentId)"
        case .saved:
            return "收藏了内容 ID: \(activity.contentId)"
        case .shared:
            return "分享了内容 ID: \(activity.contentId)"
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Recommended Project Card
struct RecommendedProjectCard: View {
    var project: RecommendedProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and difficulty
            HStack {
                Text(project.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                // Difficulty indicator
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= project.difficulty ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(index <= project.difficulty ? .yellow : .gray.opacity(0.5))
                    }
                }
            }
            
            // Title
            Text(project.title)
                .font(.headline)
                .lineLimit(2)
            
            // Description
            Text(project.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            // Start button
            Button(action: {}) {
                Text("开始学习")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 220, height: 180)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Model for recommended projects
struct RecommendedProject: Identifiable {
    var id: String
    var title: String
    var description: String
    var category: String
    var difficulty: Int // 1-5
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LearningViewModel()
        // Create a sample user with goals
        let user = User(id: "preview", name: "预览用户")
        viewModel.currentUser = user
        
        return HomeView(viewModel: viewModel)
    }
}
