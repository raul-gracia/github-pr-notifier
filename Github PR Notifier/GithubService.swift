import Foundation

class GithubService: ObservableObject {
    static let shared = GithubService()
    @Published var token: String = ""
    
    private init() {}
    
    // Fetch the GitHub username for the current authenticated user
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {

        let query = """
        {
          viewer {
            id
            login
          }
        }
        """
        
        executeGraphQLQuery(query: query) { result in
            switch result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        do {
                            let dataContainer = try JSONDecoder().decode(DataContainer.self, from: jsonData)
                            completion(.success(dataContainer.data.viewer))
                        } catch {
                            print(error)
                            completion(.failure(error))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    // Fetch pull requests where the authenticated user has been requested as a reviewer
    func fetchPullRequests(for username: String, completion: @escaping (Result<[PullRequest], Error>) -> Void) {
        let query = """
        {
          search(query: "is:pr review-requested:\(username) state:open", type: ISSUE, first: 100) {
            nodes {
              ... on PullRequest {
                id
                title
                url
                createdAt
                number
                totalCommentsCount
                reviewDecision
                repository {
                  nameWithOwner
                }
                labels(first: 100) {
                  nodes {
                    name
                    color
                  }
                }
                author {
                  login
                }
              }
            }
          }
        }
        """
        
        executeGraphQLQuery(query: query) { result in
            switch result {
                case .success(let data):
                    if let search = data["data"] as? [String: Any],
                       let nodes = search["search"] as? [String: Any],
                       let pullRequestsData = nodes["nodes"] as? [[String: Any]] {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            decoder.dateDecodingStrategy = .iso8601
                            let pullRequests = try decoder.decode([PullRequest].self, from: JSONSerialization.data(withJSONObject: pullRequestsData, options: []))
                            completion(.success(pullRequests))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse pull requests"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    private func executeGraphQLQuery(query: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "https://api.github.com/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer  \(self.token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query], options: [])
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(.success(json))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
