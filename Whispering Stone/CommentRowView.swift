import SwiftUI

struct CommentRowView: View {
    @Binding var comment: Comment
    let userId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(comment.body)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("by \(comment.authorName)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Comment like/dislike
                HStack(spacing: 12) {
                    Button {
                        Task { await likeComment() }
                    } label: {
                        Text(comment.likedBy.contains(userId)
                             ? "👍 \(comment.likeCount)"
                             : "🤍 \(comment.likeCount)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                comment.likedBy.contains(userId)
                                ? Color.blue.opacity(0.15)
                                : Color(.systemGray6)
                            )
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task { await dislikeComment() }
                    } label: {
                        Text(comment.dislikedBy.contains(userId)
                             ? "👎 \(comment.dislikeCount)"
                             : "🖤 \(comment.dislikeCount)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                comment.dislikedBy.contains(userId)
                                ? Color.red.opacity(0.15)
                                : Color(.systemGray6)
                            )
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }

    func likeComment() async {
        let snapshot = comment
        // Optimistic update
        if comment.likedBy.contains(userId) {
            comment.likedBy.removeAll { $0 == userId }
        } else {
            comment.likedBy.append(userId)
            comment.dislikedBy.removeAll { $0 == userId }
        }
        do {
            comment = try await APIService.shared.likeComment(commentId: comment.id, userId: userId)
        } catch {
            print(error)
            comment = snapshot
        }
    }

    func dislikeComment() async {
        let snapshot = comment
        // Optimistic update
        if comment.dislikedBy.contains(userId) {
            comment.dislikedBy.removeAll { $0 == userId }
        } else {
            comment.dislikedBy.append(userId)
            comment.likedBy.removeAll { $0 == userId }
        }
        do {
            comment = try await APIService.shared.dislikeComment(commentId: comment.id, userId: userId)
        } catch {
            print(error)
            comment = snapshot
        }
    }
}
