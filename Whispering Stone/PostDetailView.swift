import SwiftUI
import ClerkKit

struct PostDetailView: View {
    @Binding var post: Post
    let userId: String

    @State private var comments: [Comment] = []
    @State private var newComment = ""
    @State private var isEditing  = false
    @State private var showDeleteConfirm = false
    
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostViewModel

    var isAuthor: Bool { post.authorId == userId }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Post card
                    VStack(alignment: .leading, spacing: 10) {
                        if let tag = post.tag, !tag.isEmpty {
                            Text(tag)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color(.systemGray5)).clipShape(Capsule())
                        }

                        HStack(spacing: 6) {
                            AvatarView(name: post.authorName, size: 24)
                            Text(post.authorName ?? "Unknown")
                                .font(.caption).foregroundColor(.secondary)
                        }

                        Text(post.title ?? "")
                            .font(.title2).fontWeight(.bold)

                        Text(post.body)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 6) {
                            Text(post.timeAgo).font(.caption).foregroundColor(.secondary)
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            reactionButton(
                                label: post.likedBy.contains(userId) ? "👍 \(post.likeCount)" : "🤍 \(post.likeCount)",
                                active: post.likedBy.contains(userId),
                                activeColor: .blue
                            ) { Task { await vm.like(post: post, userId: userId) } }

                            reactionButton(
                                label: post.dislikedBy.contains(userId) ? "👎 \(post.dislikeCount)" : "🖤 \(post.dislikeCount)",
                                active: post.dislikedBy.contains(userId),
                                activeColor: .red
                            ) { Task { await vm.dislike(post: post, userId: userId) } }
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))

                    Divider()

                    // Comments
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Comments (\(comments.count))")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        ForEach($comments) { $comment in
                            CommentRowView(
                                comment: $comment,
                                userId: userId,
                                onDelete: {
                                    comments.removeAll { $0.id == comment.id }
                                },
                                onUpdate: { updated in
                                    if let i = comments.firstIndex(where: { $0.id == updated.id }) {
                                        comments[i] = updated // 🔥 force array update
                                    }
                                }
                            )
                            Divider().padding(.leading, 16)
                        }                    }
                    .background(Color(.systemBackground))

                    // Spacer so FAB doesn't cover last comment
                    Color.clear.frame(height: 90)
                }
            }
            .background(Color(.systemGroupedBackground))

            // Comment input bar (pinned to bottom)
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 10) {
                    TextField("Write a comment…", text: $newComment)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)

                    Button {
                        Task { await addComment() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(newComment.isEmpty ? .gray : .blue)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Post")
        .toolbar {
            if isAuthor {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { isEditing = true } label: {
                            Label("Edit Post", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Post", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .confirmationDialog("Delete this post?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task { 
                    await vm.deletePost(postId: post.id)
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditPostView(
                postId: post.id,
                initialTitle: post.title ?? "",
                initialBody: post.body,
                initialTag: post.tag ?? ""
            )
        }
        .task { await loadComments() }
    }

    @ViewBuilder
    private func reactionButton(label: String, active: Bool, activeColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(active ? activeColor.opacity(0.12) : Color(.systemGray6))
                .foregroundColor(active ? activeColor : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    func loadComments() async {
        do { comments = try await APIService.shared.getComments(postId: post.id) }
        catch { print(error) }
    }

    func addComment() async {
        guard !newComment.isEmpty else { return }
        let name = [clerk.user?.firstName, clerk.user?.lastName]
            .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        do {
            let c = try await APIService.shared.createComment(
                postId: post.id,
                body: ["authorId": userId, "authorName": name, "body": newComment]
            )
            comments.append(c)
            newComment = ""
        } catch { print(error) }
    }
}
