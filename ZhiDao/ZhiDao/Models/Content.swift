import Foundation

struct Content: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var summary: String
    var authors: [String]
    var year: Int?
    var type: ContentType
    var tags: [String]
    var relevanceScore: Double // 0-1
    
    enum ContentType: String, Codable {
        case academic
        case synthetic
        case userGenerated
        case news
    }
}

struct ContentCollection: Codable {
    var topic: String
    var content: [Content]
    var timestamp: Date
}

struct DeepQuestion: Identifiable, Codable {
    var id: String = UUID().uuidString
    var question: String
    var category: String
    var difficulty: Int // 1-5
}

struct CrossDisciplinaryRecommendation: Identifiable, Codable {
    var id: String = UUID().uuidString
    var area: String
    var connection: String
    var valueProposition: String
    var explorationDifficulty: Int // 1-5
}

struct DeepQuestionsResponse: Codable {
    var topic: String
    var questions: [DeepQuestion]
    var timestamp: String
}

struct CrossDisciplinaryResponse: Codable {
    var currentTopic: String
    var recommendations: [CrossDisciplinaryRecommendation]
    var explorationPercentage: Int
}
