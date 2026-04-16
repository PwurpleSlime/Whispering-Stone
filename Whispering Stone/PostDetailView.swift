import SwiftUI
import ClerkKit

struct PostDetailView: View {
    @Binding var post: Post
    let userId: String
    let onLike: () async -> Void
    let onDislike: () async -> Void

    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @Environment(Clerk.self) private var clerk

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Post Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title ?? "")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("by \(post.authorName ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(post.body)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    // Post like/dislike
                    HStack(spacing: 20) {
                        Button {
                            Task { await onLike() }
                        } label: {
                            Text(post.likedBy.contains(userId)
                                 ? "👍 \(post.likeCount)"
                                 : "🤍 \(post.likeCount)")
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    post.likedBy.contains(userId)
                                    ? Color.blue.opacity(0.15)
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { await onDislike() }
                        } label: {
                            Text(post.dislikedBy.contains(userId)
                                 ? "👎 \(post.dislikeCount)"
                                 : "🖤 \(post.dislikeCount)")
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    post.dislikedBy.contains(userId)
                                    ? Color.red.opacity(0.15)
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                Divider()

                // MARK: Comments Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments (\(comments.count))")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach($comments) { $comment in
                        CommentRowView(comment: $comment, userId: userId)
                    }
                }

                // MARK: Add Comment
                VStack(spacing: 8) {
                    TextField("Write a comment...", text: $newComment, axis: .vertical)
                        .lineLimit(3)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button {
                        Task { await addComment() }
                    } label: {
                        Text("Post Comment")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(newComment.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .task { await loadComments() }
    }

    func loadComments() async {
        do {
            comments = try await APIService.shared.getComments(postId: post.id)
        } catch {
            print(error)
        }
    }

    func addComment() async {
        guard !newComment.isEmpty else { return }
        let authorName = (clerk.user?.firstName ?? "") +
            (clerk.user?.lastName != nil ? " \(clerk.user!.lastName!)" : "")
        let body: [String: Any] = [
            "authorId": userId,
            "authorName": authorName,
            "body": newComment
        ]
        do {
            let comment = try await APIService.shared.createComment(postId: post.id, body: body)
            comments.append(comment)
            newComment = ""
        } catch {
            print(error)
        }
    }
}
