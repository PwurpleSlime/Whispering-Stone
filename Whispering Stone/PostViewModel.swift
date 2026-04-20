import Foundation
import Combine

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []

    func fetchPosts(userId: String) async {
        do { posts = try await APIService.shared.getPosts(viewerId: userId) }
        catch { print("Fetch error:", error) }
    }

    func like(post: Post, userId: String) async {
        guard let i = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let snap = posts[i]
        if posts[i].likedBy.contains(userId) { posts[i].likedBy.removeAll { $0 == userId } }
        else { posts[i].likedBy.append(userId); posts[i].dislikedBy.removeAll { $0 == userId } }
        do { posts[i] = try await APIService.shared.likePost(postId: post.id, userId: userId) }
        catch { posts[i] = snap }
    }

    func dislike(post: Post, userId: String) async {
        guard let i = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let snap = posts[i]
        if posts[i].dislikedBy.contains(userId) { posts[i].dislikedBy.removeAll { $0 == userId } }
        else { posts[i].dislikedBy.append(userId); posts[i].likedBy.removeAll { $0 == userId } }
        do { posts[i] = try await APIService.shared.dislikePost(postId: post.id, userId: userId) }
        catch { posts[i] = snap }
    }

    func createPost(title: String, body: String, tag: String, userId: String, authorName: String) async {
        do {
            let p = try await APIService.shared.createPost(body: [
                "title": title, "body": body, "tag": tag,
                "authorId": userId, "authorName": authorName
            ])
            posts.insert(p, at: 0)
        } catch { print("Create error:", error) }
    }

    func deletePost(postId: String) async {
        do {
            try await APIService.shared.deletePost(postId: postId)
            posts.removeAll { $0.id == postId }
        } catch { print("Delete error:", error) }
    }

    func updatePost(postId: String, title: String, body: String, tag: String) async {
        print("=== PostViewModel.updatePost ===")
        print("postId: '\(postId)'")
        print("title: '\(title)'")
        print("body: '\(body)'")
        print("tag: '\(tag)'")
        do {
            let updated = try await APIService.shared.updatePost(postId: postId, title: title, body: body, tag: tag)
            if let i = posts.firstIndex(where: { $0.id == postId }) { posts[i] = updated }
            print("Update successful")
        } catch { 
            print("Update error:", error)
        }
    }
}
