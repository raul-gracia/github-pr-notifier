//
//  TokenInputView.swift
//  Github PR Notifier
//
//  Created by Raul Gracia on 30/07/2023.
//

import SwiftUI

struct TokenInputView: View {
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    @State private var input: String = ""
    @ObservedObject var githubService = GithubService.shared
    
    var body: some View {
        VStack {
            Text("Enter your GitHub token")
                .font(.headline)
            SecureField("Token", text: $input)
            HStack {
                Button(action: {
                    self.isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundColor(Color.white)
                        .padding(.all, 5.0)
                        .background(Color.red)
                        .cornerRadius(5.0)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 10)
                
                Button(action: {
                    UserDefaults.standard.set(self.input, forKey: "GithubToken")
                    githubService.token = self.input
                    self.isPresented = false
                    self.onSave()
                }) {
                    Text("Save")
                        .foregroundColor(Color.white)
                        .padding(.all, 5.0)
                        .background(Color.green)
                        .cornerRadius(5.0)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 10)
            }
        }
        .padding(.all, 20.0)
    }
}


