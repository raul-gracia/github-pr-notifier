//
//  Models.swift
//  Github PR Notifier
//
//  Created by Raul Gracia on 27/07/2023.
//

import Foundation

struct PullRequest: Codable, Identifiable {
    let id: String
    let title: String
    let url: String
    let createdAt: Date
    let number: Int
    let reviewDecision: String
    let totalCommentsCount: Int
    let repository: Repository
    let labels: Labels
    let author: Author
}

struct User: Codable {
    let id: String
    let login: String
}

struct Viewer: Codable {
    let viewer: User
}

struct DataContainer: Codable {
    let data: Viewer
}

struct Repository: Codable {
    let nameWithOwner: String
}

struct Author: Codable {
    let login: String
}

struct Labels: Codable {
    let nodes: [Label]
}

struct Label: Codable, Identifiable {
    let name: String
    let color: String
    
    var id: String {
        return name
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case color
    }
}

