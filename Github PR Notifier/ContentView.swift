//
//  ContentView.swift
//  Github PR Notifier
//
//  Created by Raul Gracia on 27/07/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var pullRequests: [PullRequest] = []
    @State private var isLoading: Bool = false
    @State private var isTokenInputPresented: Bool = false
    var token: String? {
        GithubService.shared.token
    }
    @ObservedObject var githubService = GithubService.shared
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // If there's no token, show a message
                if githubService.token.isEmpty {
                    
                    VStack {
                        Spacer()
                        Text("Please set your GitHub token to load pull requests.")
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height - 50)
                } else if self.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height - 50)
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(self.pullRequests, id: \.id) { pullRequest in
                                PullRequestRow(pullRequest: pullRequest)
                            }
                            .padding(.all, 8.0)
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                HStack {
                    Button(action: {
                        NSApplication.shared.terminate(self)
                    }) {
                        Text("Quit App")
                            .foregroundColor(Color.white)
                            .padding(.all, 5.0)
                            .background(Color.red)
                            .cornerRadius(5.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 15)
                    
                    Spacer()
                    
                    Button(action: {
                        self.isTokenInputPresented = true
                    }) {
                        Text(GithubService.shared.token.isEmpty ? "Set Token" : "Change Token")
                            .foregroundColor(Color.white)
                            .padding(.all, 5.0)
                            .background(Color.green)
                            .cornerRadius(5.0)
                            .popover(isPresented: self.$isTokenInputPresented) {
                                TokenInputView(isPresented: self.$isTokenInputPresented, onSave: self.refreshPRs)
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        self.refreshPRs()
                    }) {
                        Text("Refresh")
                            .foregroundColor(Color.white)
                            .padding(.all, 5.0)
                            .background(Color.blue)
                            .cornerRadius(5.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 15)
                }
                .frame(height: 50)
            }
            .onAppear {
                self.loadToken()
                
            }
            
        }
    }
    
    private func loadToken() {
        if let storedToken = UserDefaults.standard.string(forKey: "GithubToken") {
            githubService.token = storedToken
            self.isTokenInputPresented = false
            self.refreshPRs()
        } else {
            self.isTokenInputPresented = true
        }
    }
    
    
    func refreshPRs() {
        guard !GithubService.shared.token.isEmpty else {
            print("Token is not set, aborting refreshPRs.")
            return
        }
        isLoading = true
        GithubService.shared.fetchCurrentUser { result in
            switch result {
                case .success(let user):
                    GithubService.shared.fetchPullRequests(for: user.login) { result in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            switch result {
                                case .success(let pullRequests):
                                    self.pullRequests = pullRequests
                                case .failure(let error):
                                    print("Error fetching pull requests: \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error fetching current user: \(error)")
            }
        }
    }
    
}


struct PullRequestRow: View {
    let pullRequest: PullRequest
    
    var body: some View {
        Button(action: {
            if let url = URL(string: pullRequest.url) {
                NSWorkspace.shared.open(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image("LogoIcon")
                    Text(pullRequest.repository.nameWithOwner).font(.headline).foregroundColor(Color("Text Color"))
                    Spacer()
                }
                Text(pullRequest.title).font(.headline).foregroundColor(Color("Text Color"))
                HStack {
                    ForEach(pullRequest.labels.nodes) { label in
                        Text(label.name)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: label.color))
                            .foregroundColor(Color(hex: label.color).isLight() ? .black : .white)
                            .cornerRadius(8)
                    }
                }
                
                HStack {
                    Text("#\(pullRequest.number) ")
                    + Text("opened \(dateToRelativeTime(date: pullRequest.createdAt)) ")
                    + Text("by \(pullRequest.author.login) ")
                    + Text("• \(pullRequest.reviewDecision.humanize())")
                    Spacer()
                    Image("CommentsIcon")
                    Text("\(pullRequest.totalCommentsCount)")
                }
                .foregroundColor(Color("Text Color"))
            }
            .padding()
            .background(Color("BG Color"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .padding([.horizontal])
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func dateToRelativeTime(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
        return relativeDate
    }
}
