import Foundation

final class APIService {
    static let shared = APIService()

    private let baseURL = "http://127.0.0.1:3014"

    // MARK: - Core Request (FIXED: explicit type parameter)

    func request<T: Decodable>(
        type: T.Type,
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // Optional: better debugging if backend fails
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            print("HTTP Error:", http.statusCode)
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - POSTS

    func getPosts(viewerId: String) async throws -> [Post] {
        return try await request(
            type: [Post].self,
            endpoint: "/posts?viewerId=\(viewerId)",
        )
    }

    func createPost(body: [String: Any]) async throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: body)

        return try await request(
            type: Post.self,
            endpoint: "/posts/upsert",
            method: "POST",
            body: data
        )
    }

    func likePost(postId: String, userId: String) async throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])

        return try await request(
            type: Post.self,
            endpoint: "/posts/\(postId)/like",
            method: "PATCH",
            body: data
        )
    }

    func dislikePost(postId: String, userId: String) async throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])

        return try await request(
            type: Post.self,
            endpoint: "/posts/\(postId)/dislike",
            method: "PATCH",
            body: data
        )
    }

    // MARK: - COMMENTS

    func getComments(postId: String) async throws -> [Comment] {
        return try await request(
            type: [Comment].self,
            endpoint: "/comments/post/\(postId)"
        )
    }

    func createComment(postId: String, body: [String: Any]) async throws -> Comment {
        let data = try JSONSerialization.data(withJSONObject: body)

        return try await request(
            type: Comment.self,
            endpoint: "/comments/post/\(postId)",
            method: "POST",
            body: data
        )
    }

    func deleteComment(commentId: String) async throws {
        _ = try await request(
            type: EmptyResponse.self,
            endpoint: "/comments/\(commentId)",
            method: "DELETE"
        )
    }
    func likeComment(commentId: String, userId: String) async throws -> Comment {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])
        return try await request(
            type: Comment.self,
            endpoint: "/comments/\(commentId)/like",
            method: "PATCH",
            body: data
        )
    }

    func dislikeComment(commentId: String, userId: String) async throws -> Comment {
        let data = try JSONSerialization.data(withJSONObject: ["userId": userId])
        return try await request(
            type: Comment.self,
            endpoint: "/comments/\(commentId)/dislike",
            method: "PATCH",
            body: data
        )
    }
}

// MARK: - Helper for DELETE endpoints
struct EmptyResponse: Decodable {}
