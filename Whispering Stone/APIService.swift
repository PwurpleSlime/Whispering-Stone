import Foundation

final class APIService {
    static let shared = APIService()
    private let baseURL = "https://whispering-stone-backend.vercel.app"

    func request<T: Decodable>(
        type: T.Type, endpoint: String,
        method: String = "GET", body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            print("HTTP Error:", http.statusCode)
            print(String(data: data, encoding: .utf8) ?? "")
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Posts
    func getPosts(viewerId: String) async throws -> [Post] {
        try await request(type: [Post].self, endpoint: "/posts?viewerId=\(viewerId)")
    }
    func createPost(body: [String: Any]) async throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await request(type: Post.self, endpoint: "/posts/upsert", method: "POST", body: data)
    }
    func updatePost(postId: String, title: String, body: String, tag: String) async throws -> Post {
        // Force copy to ensure strings are retained across async boundary
        let safeTitle = String(title)
        let safeBody = String(body)
        let safeTag = String(tag)
        
        print("=== APIService.updatePost ===")
        print("postId: '\(postId)'")
        print("title: '\(safeTitle)'")
        print("body: '\(safeBody)'")
        print("tag: '\(safeTag)'")
        
        let payload: [String: String] = [
            "title": safeTitle,
            "body": safeBody,
            "tag": safeTag
        ]
        
        print("Payload dictionary: \(payload)")
        
        let data = try JSONSerialization.data(withJSONObject: payload)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON being sent: \(jsonString)")
        }
        
        return try await request(type: Post.self, endpoint: "/posts/upsert/\(postId)", method: "POST", body: data)
    }
    func deletePost(postId: String) async throws {
        _ = try await request(type: EmptyResponse.self, endpoint: "/posts/\(postId)", method: "DELETE")
    }
    func likePost(postId: String, userId: String) async throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])
        return try await request(type: Post.self, endpoint: "/posts/\(postId)/like", method: "PATCH", body: data)
    }
    func dislikePost(postId: String, userId: String) async throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])
        return try await request(type: Post.self, endpoint: "/posts/\(postId)/dislike", method: "PATCH", body: data)
    }

    // MARK: - Comments
    func getComments(postId: String) async throws -> [Comment] {
        try await request(type: [Comment].self, endpoint: "/comments/post/\(postId)")
    }
    func createComment(postId: String, body: [String: Any]) async throws -> Comment {
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await request(type: Comment.self, endpoint: "/comments/post/\(postId)", method: "POST", body: data)
    }
    func updateComment(commentId: String, body: String) async throws -> Comment {
        print(commentId)
        
        let data = try JSONSerialization.data(withJSONObject: ["body": body])
        return try await request(type: Comment.self, endpoint: "/comments/\(commentId)", method: "PATCH", body: data)
    }
    func deleteComment(commentId: String) async throws {
        _ = try await request(type: EmptyResponse.self, endpoint: "/comments/\(commentId)", method: "DELETE")
    }
    func likeComment(commentId: String, userId: String) async throws -> Comment {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])
        return try await request(type: Comment.self, endpoint: "/comments/\(commentId)/like", method: "PATCH", body: data)
    }
    func dislikeComment(commentId: String, userId: String) async throws -> Comment {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])
        return try await request(type: Comment.self, endpoint: "/comments/\(commentId)/dislike", method: "PATCH", body: data)
    }
}

struct EmptyResponse: Decodable {}
