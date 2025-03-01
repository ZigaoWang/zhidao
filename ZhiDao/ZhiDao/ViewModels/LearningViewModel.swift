import Foundation
import Combine

class LearningViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    
    @Published var learningPath: LearningPath?
    @Published var contentCollection: ContentCollection?
    
    @Published var currentTopic: String = ""
    @Published var deepQuestions: [DeepQuestion] = []
    @Published var crossDisciplinaryRecommendations: [CrossDisciplinaryRecommendation] = []
    @Published var explorationPercentage: Int = 0
    
    private let apiService = APIService.shared
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSavedUserData()
    }
    
    // MARK: - User Data Persistence
    
    private func loadSavedUserData() {
        if let userData = userDefaults.data(forKey: "currentUser") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let user = try? decoder.decode(User.self, from: userData) {
                self.currentUser = user
                
                // Set current topic to most recent goal if available
                if let mostRecentGoal = user.learningGoals.sorted(by: { $0.createdAt > $1.createdAt }).first {
                    self.currentTopic = mostRecentGoal.goal
                }
            }
        }
    }
    
    private func saveUserData() {
        guard let user = currentUser else { return }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let encoded = try? encoder.encode(user) {
            userDefaults.set(encoded, forKey: "currentUser")
        }
    }
    
    // MARK: - User Initialization
    
    func createTemporaryUser() {
        let uuid = UUID().uuidString
        self.currentUser = User(id: uuid, name: "用户 \(String(uuid.prefix(4)))")
        saveUserData()
    }
    
    // MARK: - Sample Projects
    
    func createSampleProjects() {
        let sampleProjects = [
            (goal: "人工智能基础", timeframe: "3月", priority: LearningGoal.GoalPriority.medium, progress: 15),
            (goal: "中国古代哲学", timeframe: "6月", priority: LearningGoal.GoalPriority.low, progress: 30)
        ]
        
        for project in sampleProjects {
            let goalId = UUID().uuidString
            let newGoal = LearningGoal(
                id: goalId,
                goal: project.goal,
                timeframe: project.timeframe,
                priority: project.priority,
                createdAt: Date().addingTimeInterval(-Double.random(in: 86400...604800)), // 1-7 days ago
                progress: project.progress,
                relatedTopics: getRelatedTopics(for: project.goal)
            )
            
            // Add sample activities
            let activityTypes: [LearningActivity.ActivityType] = [.viewed, .completed]
            for _ in 1...3 {
                let activity = LearningActivity(
                    id: UUID().uuidString,
                    contentId: "sample-\(UUID().uuidString.prefix(8))",
                    action: activityTypes.randomElement() ?? .viewed,
                    timestamp: Date().addingTimeInterval(-Double.random(in: 3600...259200)) // 1-3 days ago
                )
                currentUser?.learningHistory.append(activity)
            }
            
            currentUser?.learningGoals.append(newGoal)
        }
        
        saveUserData()
    }
    
    private func getRelatedTopics(for goal: String) -> [String] {
        switch goal {
        case "人工智能基础":
            return ["机器学习", "神经网络", "深度学习", "数据科学"]
        case "中国古代哲学":
            return ["儒家思想", "道家思想", "墨家", "法家"]
        case "量子计算入门":
            return ["量子力学", "量子比特", "量子算法", "量子纠缠"]
        case "宏观经济学":
            return ["GDP", "通货膨胀", "经济周期", "财政政策"]
        default:
            return []
        }
    }
    
    // MARK: - Goal Setting
    
    func createLearningGoal(goal: String, timeframe: String, priority: LearningGoal.GoalPriority) {
        guard let userId = currentUser?.id else { return }
        
        isLoading = true
        error = nil
        
        apiService.createLearningGoal(userId: userId, goal: goal, timeframe: timeframe, priority: priority) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let (goalId, learningPath)):
                    // Create a new learning goal locally
                    let newGoal = LearningGoal(
                        id: goalId,
                        goal: goal,
                        timeframe: timeframe,
                        priority: priority,
                        createdAt: Date(),
                        progress: 0,
                        relatedTopics: self?.getRelatedTopics(for: goal) ?? []
                    )
                    
                    // Update the user's goals
                    self?.currentUser?.learningGoals.append(newGoal)
                    
                    // Save user data
                    self?.saveUserData()
                    
                    // Update the current learning path
                    self?.learningPath = learningPath
                    
                    // Set the current topic to the main goal
                    self?.currentTopic = goal
                    
                    // Fetch initial content for the goal
                    self?.fetchContentForCurrentTopic()
                    
                case .failure(let error):
                    self?.error = error.localizedDescription
                    
                    // Create a fallback learning path if API fails
                    self?.createFallbackLearningPath(for: goal)
                }
            }
        }
    }
    
    // MARK: - Progress Tracking
    
    func updateProgressForCurrentGoal(increment: Int = 5) {
        guard let currentGoal = getCurrentGoal() else { return }
        
        // Find the goal index
        if let index = currentUser?.learningGoals.firstIndex(where: { $0.id == currentGoal.id }) {
            // Increment progress but cap it at 100%
            let newProgress = min(currentUser?.learningGoals[index].progress ?? 0 + increment, 100)
            currentUser?.learningGoals[index].progress = newProgress
            
            // Save user data
            saveUserData()
        }
    }
    
    func getCurrentGoal() -> LearningGoal? {
        return currentUser?.learningGoals.first(where: { $0.goal == currentTopic })
    }
    
    func switchTopic(to topic: String) {
        self.currentTopic = topic
        self.contentCollection = nil
        self.learningPath = nil
        self.deepQuestions = []
        self.crossDisciplinaryRecommendations = []
        
        // Fetch content for the new topic
        fetchContentForCurrentTopic()
    }
    
    // MARK: - Activity Recording
    
    func recordActivity(contentId: String, action: LearningActivity.ActivityType) {
        guard let userId = currentUser?.id, 
              let currentGoal = getCurrentGoal() else { return }
        
        let activity = LearningActivity(
            id: UUID().uuidString,
            contentId: contentId,
            action: action,
            timestamp: Date()
        )
        
        // Add to local history
        currentUser?.learningHistory.append(activity)
        
        // Update progress based on activity
        if action == .completed {
            updateProgressForCurrentGoal(increment: 10)
        } else if action == .viewed {
            updateProgressForCurrentGoal(increment: 3)
        }
        
        // Save user data
        saveUserData()
        
        // Send to API if connected
        apiService.recordLearningActivity(userId: userId, activity: activity) { [weak self] result in 
            // Logging only, no UI update needed
            print("Recorded activity: \(action) for content: \(contentId)")
        }
    }
    
    private func createFallbackLearningPath(for topic: String) {
        // Create a fallback learning path with basic structure for offline use
        learningPath = LearningPath(
            foundational: ["基础概念: \(topic)", "历史背景", "核心原理"],
            intermediate: ["应用场景", "关键技术", "常见问题"],
            advanced: ["前沿研究", "理论深化", "高级应用"],
            projects: ["初级项目", "实践案例", "创新应用"]
        )
    }
    
    // MARK: - Content Fetching
    
    func fetchContentForCurrentTopic() {
        guard !currentTopic.isEmpty else { 
            self.error = "当前主题为空，无法获取内容"
            return 
        }
        
        print("开始获取主题内容: \(currentTopic)")
        isLoading = true
        error = nil
        
        apiService.fetchContent(topic: currentTopic) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let contentCollection):
                    print("成功获取内容，项目数量: \(contentCollection.content.count)")
                    self.contentCollection = contentCollection
                    
                    // After fetching content, get deep questions
                    self.fetchDeepQuestions()
                    
                case .failure(let error):
                    print("获取内容失败: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                    
                    // Create default content if API fails
                    if self.contentCollection == nil {
                        print("使用默认内容")
                        let defaultContents = self.createDefaultContent(for: self.currentTopic)
                        self.contentCollection = ContentCollection(
                            topic: self.currentTopic,
                            content: defaultContents,
                            timestamp: Date()
                        )
                    }
                    
                    // Still try to fetch questions even if content fails
                    self.fetchDeepQuestions()
                }
            }
        }
    }
    
    // MARK: - Deep Questions
    
    func fetchDeepQuestions() {
        guard !currentTopic.isEmpty else { return }
        
        apiService.fetchDeepQuestions(topic: currentTopic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    self?.deepQuestions = questions
                    
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Progress Tracking
    
    func recordContentInteraction(contentId: String, action: LearningActivity.ActivityType, duration: TimeInterval? = nil) {
        guard let userId = currentUser?.id else { return }
        
        apiService.recordProgress(userId: userId, contentId: contentId, action: action, duration: duration) { [weak self] result in
            switch result {
            case .success:
                // Create a new activity locally
                let newActivity = LearningActivity(
                    contentId: contentId,
                    action: action,
                    duration: duration,
                    timestamp: Date()
                )
                
                // Update the user's activity history
                DispatchQueue.main.async {
                    self?.currentUser?.learningHistory.append(newActivity)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Learning Path Interaction
    
    func recordLearningPathInteraction(item: String) {
        // For now, just print a message for debugging
        print("User interacted with learning path item: \(item)")
        
        // In a full implementation, you would record this interaction
        // to track user progress through the learning path
        
        // Example: Could be implemented similarly to recordContentInteraction
        // by creating a custom activity type for learning path items
    }
    
    // MARK: - Cross-disciplinary Recommendations
    
    func fetchCrossDisciplinaryRecommendations() {
        guard let userId = currentUser?.id, !currentTopic.isEmpty else { return }
        
        apiService.fetchCrossDisciplinaryRecommendations(userId: userId, currentTopic: currentTopic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (recommendations, explorationPercentage)):
                    self?.crossDisciplinaryRecommendations = recommendations
                    self?.explorationPercentage = explorationPercentage
                    
                    // Update the user's explored topics
                    self?.currentUser?.exploredTopics[self?.currentTopic ?? ""] = explorationPercentage
                    
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Learning Path Fetching
    
    func fetchLearningPath() {
        guard let userId = currentUser?.id, !currentTopic.isEmpty else { return }
        
        isLoading = true
        
        apiService.fetchLearningPath(userId: userId, topic: currentTopic) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let learningPath):
                    self?.learningPath = learningPath
                    
                case .failure(let error):
                    self?.error = error.localizedDescription
                    // Create a fallback learning path if API fails
                    self?.createFallbackLearningPath(for: self?.currentTopic ?? "一般主题")
                }
            }
        }
    }
    
    private func createDefaultContent(for topic: String) -> [Content] {
        // Create default content items for offline/development use
        return [
            Content(
                id: "default-1",
                title: "基础概念 - \(topic)",
                summary: "这是关于\(topic)的基础概念和入门知识",
                authors: ["专家 张"],
                year: 2024,
                type: .academic,
                tags: ["基础", "入门"],
                relevanceScore: 0.95
            ),
            Content(
                id: "default-2",
                title: "应用案例 - \(topic)",
                summary: "实际应用中的\(topic)案例分析",
                authors: ["教授 李"],
                year: 2023,
                type: .synthetic,
                tags: ["应用", "案例"],
                relevanceScore: 0.88
            ),
            Content(
                id: "default-3",
                title: "最新进展 - \(topic)",
                summary: "\(topic)领域的最新研究成果和趋势",
                authors: ["研究员 王"],
                year: 2024,
                type: .news,
                tags: ["研究", "趋势"],
                relevanceScore: 0.78
            )
        ]
    }
}
