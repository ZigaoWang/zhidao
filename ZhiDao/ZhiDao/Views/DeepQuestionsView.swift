import SwiftUI

struct DeepQuestionsView: View {
    @ObservedObject var viewModel: LearningViewModel
    @State private var selectedQuestion: DeepQuestion?
    @State private var showingAnswer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("深度问题")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("探索这些深入的思考性问题，加深你的理解")
                    .foregroundColor(.secondary)
                
                // Questions list
                if viewModel.deepQuestions.isEmpty {
                    if viewModel.isLoading {
                        ProgressView("加载问题中...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        Text("没有可用的问题。请尝试其他主题。")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    ForEach(viewModel.deepQuestions) { question in
                        Button(action: {
                            selectedQuestion = question
                            showingAnswer = true
                        }) {
                            QuestionCardView(question: question)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
            .navigationTitle("深度问题")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.deepQuestions.isEmpty {
                    viewModel.fetchDeepQuestions()
                }
            }
            .sheet(isPresented: $showingAnswer, onDismiss: { selectedQuestion = nil }) {
                if let question = selectedQuestion {
                    QuestionDetailView(question: question, topic: viewModel.currentTopic)
                }
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        
                        ProgressView("加载...")
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
}

struct QuestionCardView: View {
    var question: DeepQuestion
    
    var difficultyColor: Color {
        switch question.difficulty {
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question text
            Text(question.question)
                .font(.headline)
                .lineLimit(3)
            
            // Metadata row
            HStack {
                // Category
                Text(question.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                
                Spacer()
                
                // Difficulty indicator
                HStack(spacing: 5) {
                    Text("难度:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(i <= question.difficulty ? difficultyColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct QuestionDetailView: View {
    var question: DeepQuestion
    var topic: String
    @State private var generatedAnswer: String = ""
    @State private var isLoading = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Question
                    VStack(alignment: .leading, spacing: 12) {
                        Text("问题:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(question.question)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Category and difficulty
                    HStack {
                        Label(
                            title: { Text(question.category).font(.subheadline) },
                            icon: { Image(systemName: "tag.fill").foregroundColor(.blue) }
                        )
                        
                        Spacer()
                        
                        Label(
                            title: { Text("难度: \(question.difficulty)/5").font(.subheadline) },
                            icon: { Image(systemName: "chart.bar.fill").foregroundColor(.orange) }
                        )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Generated answer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("思考点:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if isLoading {
                            ProgressView("正在为你思考这个问题...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            Text(generatedAnswer)
                                .font(.body)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("深度问题")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // In a real app, this would call an API to generate an answer
                // For now, we'll simulate it with a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    generateThoughtsAboutQuestion()
                    isLoading = false
                }
            }
        }
    }
    
    private func generateThoughtsAboutQuestion() {
        // This would normally call the API to generate an answer
        // For now, we'll use a placeholder
        generatedAnswer = """
        这是一个关于\(topic)的有趣问题，它涉及多个重要方面。
        
        从一个角度来看，我们可以考虑\(topic)涉及复杂的交互，包括技术可行性、伦理考虑和实际应用。
        
        另一方面，有不同的观点认为应该重新思考这个问题。一些领域的专家提出了不同的方法。
        
        最近的研究表明了令人鼓舞的结果，尽管还有很多挑战需要克服。
        
        如果你想进一步探索这个问题，你可能需要：
        
        1. 探索这个问题的历史背景
        2. 研究不同的理论框架
        3. 研究实际案例
        4. 探索新的研究
        
        你最感兴趣的是这个问题的哪个方面？
        """
    }
}

struct DeepQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeepQuestionsView(viewModel: LearningViewModel())
        }
    }
}
