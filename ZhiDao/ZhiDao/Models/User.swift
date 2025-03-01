import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String?
    var learningGoals: [LearningGoal]
    var learningHistory: [LearningActivity]
    var exploredTopics: [String: Int] // Topic name: exploration percentage
    
    init(id: String, name: String, email: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.learningGoals = []
        self.learningHistory = []
        self.exploredTopics = [:]
    }
}

struct LearningGoal: Identifiable, Codable, Hashable {
    var id: String
    var goal: String
    var timeframe: String
    var priority: GoalPriority
    var createdAt: Date
    var progress: Int // 0-100
    var relatedTopics: [String]
    
    enum GoalPriority: String, Codable, Hashable {
        case low
        case medium
        case high
    }
}

struct LearningActivity: Identifiable, Codable {
    var id: String = UUID().uuidString
    var contentId: String
    var action: ActivityType
    var duration: TimeInterval?
    var timestamp: Date
    
    enum ActivityType: String, Codable {
        case viewed
        case completed
        case saved
        case shared
    }
}
