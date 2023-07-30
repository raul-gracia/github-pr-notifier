//
//  ContentView.swift
//  Github PR Notifier
//
//  Created by Raul Gracia on 27/07/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var pullRequests: [PullRequest] = []
    
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(pullRequests, id: \.id) { pullRequest in
                        PullRequestRow(pullRequest: pullRequest)
                    }
                    .padding(.all, 8.0)
                }
            }
            .padding(.bottom, 5)
            
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
                    refreshPRs()
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
            .frame(height: 30)
        }
        .onAppear {
            GithubService.shared.fetchCurrentUser { result in
                switch result {
                    case .success(let user):
                        GithubService.shared.fetchPullRequests(for: user.login) { result in
                            DispatchQueue.main.async {
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
    
    func refreshPRs() {
        GithubService.shared.fetchCurrentUser { result in
            switch result {
                case .success(let user):
                    GithubService.shared.fetchPullRequests(for: user.login) { result in
                        DispatchQueue.main.async {
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
            // Make sure to safely unwrap the URL
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
