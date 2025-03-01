//
//  ContentView.swift
//  ZhiDao
//
//  Created by Zigao Wang on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LearningViewModel()
    
    var body: some View {
        HomeView(viewModel: viewModel)
            .onAppear {
                // Create a default user if none exists
                if viewModel.currentUser == nil {
                    let userId = UUID().uuidString
                    let user = User(id: userId, name: "用户")
                    viewModel.currentUser = user
                    viewModel.saveUserData()
                }
            }
    }
}

#Preview {
    ContentView()
}
