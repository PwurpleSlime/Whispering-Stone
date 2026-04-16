import Foundation
import Combine

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []

    func fetchPosts(userId: String) async {
        do {
            posts = try await APIService.shared.getPosts(viewerId: userId)
        } catch {
            print("Error fetching posts:", error)
        }
    }

    func like(post: Post, userId: String) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let snapshot = posts[index]

        // ✅ Optimistic: only touch arrays, counts auto-update via computed property
        if posts[index].likedBy.contains(userId) {
            posts[index].likedBy.removeAll { $0 == userId }
        } else {
            posts[index].likedBy.append(userId)
            posts[index].dislikedBy.removeAll { $0 == userId }
        }

        do {
            let updated = try await APIService.shared.likePost(postId: post.id, userId: userId)
            posts[index] = updated
        } catch {
            print(error)
            posts[index] = snapshot
        }
    }

    func dislike(post: Post, userId: String) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let snapshot = posts[index]

        // ✅ Optimistic: only touch arrays
        if posts[index].dislikedBy.contains(userId) {
            posts[index].dislikedBy.removeAll { $0 == userId }
        } else {
            posts[index].dislikedBy.append(userId)
            posts[index].likedBy.removeAll { $0 == userId }
        }

        do {
            let updated = try await APIService.shared.dislikePost(postId: post.id, userId: userId)
            posts[index] = updated
        } catch {
            print(error)
            posts[index] = snapshot
        }
    }
}
