# ZhiDao - AI-Powered Learning Tool

ZhiDao (智道) is an intelligent learning tool designed for educators and lifelong learners. It helps users track cutting-edge knowledge in their fields of interest, providing personalized learning paths, deep questions, and cross-disciplinary connections.

## Features

- **Content Learning**: Get the latest content on your chosen topics with relevance indicators and tags
- **Goal Setting**: Set learning goals with timeframes and priorities
- **Learning Paths**: Receive personalized paths with foundational, intermediate, and advanced topics
- **Deep Questions**: Explore thought-provoking questions to deepen your understanding
- **Cross-Disciplinary Exploration**: Discover related fields and connections to expand your knowledge

## Project Structure

### Server Component

Located in `/Users/zigaowang/Documents/GitHub/ai-search/`, the server provides the backend API for:

- User goal management
- Content retrieval and synthesis
- Learning path generation
- Deep question generation
- Cross-disciplinary recommendations

### iOS Client

Located in `/Users/zigaowang/Documents/IT Stuff/iOS Development/zhidao/ZhiDao/`, the iOS client provides:

- User interface for setting goals
- Content browsing and interaction
- Learning path visualization
- Deep question exploration
- Cross-disciplinary discovery

## Setup Instructions

### Server Setup

1. Navigate to the server directory:
   ```
   cd /Users/zigaowang/Documents/GitHub/ai-search/
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a `.env` file with the required API keys:
   ```
   OPENAI_API_KEY=your_api_key_here
   PORT=3000
   ```

4. Start the server:
   ```
   npm start
   ```

### iOS App Setup

1. Open the ZhiDao project in Xcode:
   ```
   open /Users/zigaowang/Documents/IT\ Stuff/iOS\ Development/zhidao/ZhiDao/ZhiDao.xcodeproj
   ```

2. Update the API base URL in `APIService.swift` if needed (default is `http://localhost:3000/api`)

3. Build and run the app in the iOS simulator or on a physical device

## Flow Diagram

The app follows this user flow:
1. Start app
2. User inputs learning goal
3. System analyzes information and displays content
4. User explores learning path and content
5. User can dive into deep questions about the topic
6. Cross-disciplinary recommendations help expand knowledge

## Future Enhancements

- Community features for user content contributions
- Micro-documentary generation (AI-generated 5-minute explanatory videos)
- Innovation sandbox (simulating technology applications)
- Debate arena (AI-generated opposing viewpoint trees)
- Fatigue detection mechanism to prevent information overload

## Target Audiences

- **Primary**: Educators (teachers, trainers, course designers)
- **Secondary**: Learners, cross-disciplinary innovators, investors, lifelong learners

## License

[MIT License](LICENSE)
