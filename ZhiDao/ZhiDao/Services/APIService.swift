import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000/api"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Learning Goal API
    
    func createLearningGoal(userId: String, goal: String, timeframe: String, priority: LearningGoal.GoalPriority, completion: @escaping (Result<(goalId: String, learningPath: LearningPath), Error>) -> Void) {
        let endpoint = "\(baseURL)/goals"
        
        // Create request body
        let parameters: [String: Any] = [
            "userId": userId,
            "goal": goal,
            "timeframe": timeframe,
            "priority": priority.rawValue
        ]
        
        // Create and configure request
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode request body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(APIError.encodingFailed))
            return
        }
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                // Parse the response
                let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                guard let goalId = responseDict?["goalId"] as? String,
                      let learningPathDict = responseDict?["learningPath"] as? [String: Any],
                      let foundational = learningPathDict["foundational"] as? [String],
                      let intermediate = learningPathDict["intermediate"] as? [String],
                      let advanced = learningPathDict["advanced"] as? [String],
                      let projects = learningPathDict["projects"] as? [String] else {
                    completion(.failure(APIError.decodingFailed))
                    return
                }
                
                let learningPath = LearningPath(
                    foundational: foundational,
                    intermediate: intermediate,
                    advanced: advanced,
                    projects: projects
                )
                
                completion(.success((goalId, learningPath)))
                
            } catch {
                completion(.failure(APIError.decodingFailed))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Content API
    
    func fetchContent(topic: String, completion: @escaping (Result<ContentCollection, Error>) -> Void) {
        let endpoint = "\(baseURL)/content?topic=\(topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                // Print the raw data for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response for content: \(jsonString)")
                }
                
                // Parse the response
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let contentCollection = try decoder.decode(ContentCollection.self, from: data)
                    completion(.success(contentCollection))
                } catch let decodingError as DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: \(type), path: \(context.codingPath), debug description: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type), path: \(context.codingPath), debug description: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key), path: \(context.codingPath), debug description: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription), coding path: \(context.codingPath)")
                    @unknown default:
                        print("Unknown decoding error: \(decodingError)")
                    }
                    
                    // Try parsing with a manual approach
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("JSON structure: \(jsonObject.keys)")
                        
                        // Create a mock content collection if needed for development/testing
                        if jsonObject["topic"] != nil {
                            let mockCollection = self.createMockContentCollection(for: topic)
                            completion(.success(mockCollection))
                            return
                        }
                    }
                    
                    completion(.failure(APIError.decodingFailed))
                }
            } catch {
                print("General error during content decoding: \(error)")
                completion(.failure(APIError.decodingFailed))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Mock Content Generation (for development/testing)
    
    private func createMockContentCollection(for topic: String) -> ContentCollection {
        let mockContents = [
            Content(
                id: "1",
                title: "基础概念 - \(topic)",
                summary: "这是关于\(topic)主题的基础概念介绍",
                authors: ["教授 李"],
                year: 2023,
                type: .academic,
                tags: ["基础", "入门"],
                relevanceScore: 0.95
            ),
            Content(
                id: "2",
                title: "高级应用 - \(topic)",
                summary: "这是\(topic)的高级应用实例",
                authors: ["专家 张"],
                year: 2024,
                type: .synthetic,
                tags: ["高级", "应用"],
                relevanceScore: 0.85
            )
        ]
        
        return ContentCollection(
            topic: topic,
            content: mockContents,
            timestamp: Date()
        )
    }
    
    // MARK: - Deep Questions API
    
    func fetchDeepQuestions(topic: String, completion: @escaping (Result<[DeepQuestion], Error>) -> Void) {
        let endpoint = "\(baseURL)/questions?topic=\(topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // Print the raw data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response for questions: \(jsonString)")
            }
            
            // Decode directly to the response model
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(DeepQuestionsResponse.self, from: data)
                completion(.success(response.questions))
            } catch {
                print("Deep questions decoding error: \(error)")
                
                // Provide mock data for testing
                let mockQuestions = [
                    DeepQuestion(
                        question: "什么是\(topic)的核心原理？",
                        category: "原理",
                        difficulty: 3
                    ),
                    DeepQuestion(
                        question: "\(topic)如何应用于实际场景？",
                        category: "应用",
                        difficulty: 4
                    )
                ]
                completion(.success(mockQuestions))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Cross-disciplinary Recommendations API
    
    func fetchCrossDisciplinaryRecommendations(userId: String, currentTopic: String, completion: @escaping (Result<([CrossDisciplinaryRecommendation], Int), Error>) -> Void) {
        let endpoint = "\(baseURL)/recommendations/cross-disciplinary?userId=\(userId)&currentTopic=\(currentTopic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // Print the raw data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response for recommendations: \(jsonString)")
            }
            
            // Decode directly to the response model
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(CrossDisciplinaryResponse.self, from: data)
                completion(.success((response.recommendations, response.explorationPercentage)))
            } catch {
                print("Cross-disciplinary recommendations decoding error: \(error)")
                
                // Provide mock data for testing
                let mockRecommendations = [
                    CrossDisciplinaryRecommendation(
                        area: "物理学",
                        connection: "\(currentTopic)与物理学有许多相似的概念",
                        valueProposition: "学习物理学可以帮助你更好地理解\(currentTopic)的基本原理",
                        explorationDifficulty: 3
                    ),
                    CrossDisciplinaryRecommendation(
                        area: "心理学",
                        connection: "心理学视角可以帮助理解\(currentTopic)的应用场景",
                        valueProposition: "心理学提供了理解人类行为的框架，可以应用到\(currentTopic)的学习中",
                        explorationDifficulty: 2
                    )
                ]
                completion(.success((mockRecommendations, 40)))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Learning Path API
    
    func fetchLearningPath(userId: String, topic: String, completion: @escaping (Result<LearningPath, Error>) -> Void) {
        let endpoint = "\(baseURL)/learning-path?userId=\(userId)&topic=\(topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // Print the raw data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response for learning path: \(jsonString)")
            }
            
            // Decode directly to the response model
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(LearningPath.self, from: data)
                completion(.success(response))
            } catch {
                print("Learning path decoding error: \(error)")
                
                // Provide mock data for testing
                let mockLearningPath = LearningPath(
                    foundational: ["基础概念: \(topic)", "历史背景", "核心原理"],
                    intermediate: ["应用场景", "关键技术", "常见问题"],
                    advanced: ["前沿研究", "理论深化", "高级应用"],
                    projects: ["初级项目", "实践案例", "创新应用"]
                )
                completion(.success(mockLearningPath))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Progress API
    
    func recordProgress(userId: String, contentId: String, action: LearningActivity.ActivityType, duration: TimeInterval? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/progress"
        
        // Create request body
        var parameters: [String: Any] = [
            "userId": userId,
            "contentId": contentId,
            "action": action.rawValue
        ]
        
        if let duration = duration {
            parameters["duration"] = duration
        }
        
        // Create and configure request
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode request body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(APIError.encodingFailed))
            return
        }
        
        // Make the request
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }
    
    // MARK: - Learning Activity API
    
    func recordLearningActivity(userId: String, activity: LearningActivity, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/activities"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let activityRequest = [
            "userId": userId,
            "contentId": activity.contentId,
            "action": activity.action.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: activity.timestamp)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: activityRequest)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }
}

// MARK: - API Errors

enum APIError: Error {
    case invalidURL
    case encodingFailed
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingFailed
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingFailed:
            return "Failed to encode request data"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noData:
            return "No data received from server"
        case .decodingFailed:
            return "Failed to decode response data"
        }
    }
}
