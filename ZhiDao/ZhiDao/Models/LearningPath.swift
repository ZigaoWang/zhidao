import Foundation

struct LearningPath: Codable {
    var foundational: [String]
    var intermediate: [String]
    var advanced: [String]
    var projects: [String]
    
    init(foundational: [String] = [], intermediate: [String] = [], advanced: [String] = [], projects: [String] = []) {
        self.foundational = foundational
        self.intermediate = intermediate
        self.advanced = advanced
        self.projects = projects
    }
}
