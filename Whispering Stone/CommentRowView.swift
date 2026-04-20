import SwiftUI

struct CommentRowView: View {
    @Binding var comment: Comment
    let userId: String
    let onDelete: () -> Void
    let onUpdate: (Comment) -> Void
    
    @State private var isEditing  = false
    @State private var editedBody = ""
    @State private var showDeleteConfirm = false

    var isAuthor: Bool { comment.authorId == userId }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                AvatarView(name: comment.authorName, size: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.authorName)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.primary)

                    Text(comment.body)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if isAuthor {
                    Menu {
                        Button {
                            editedBody = comment.body
                            isEditing = true
                        } label: { Label("Edit", systemImage: "pencil") }

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: { Label("Delete", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                            .padding(6)
                    }
                }
            }

            HStack(spacing: 12) {
                Spacer()
                reactionButton(
                    label: comment.likedBy.contains(userId) ? "👍 \(comment.likeCount)" : "🤍 \(comment.likeCount)",
                    active: comment.likedBy.contains(userId), activeColor: .blue
                ) { Task { await likeComment() } }

                reactionButton(
                    label: comment.dislikedBy.contains(userId) ? "👎 \(comment.dislikeCount)" : "🖤 \(comment.dislikeCount)",
                    active: comment.dislikedBy.contains(userId), activeColor: .red
                ) { Task { await dislikeComment() } }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .confirmationDialog("Delete this comment?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    try? await APIService.shared.deleteComment(commentId: comment.id)
                    onDelete()
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditCommentSheet(mainContent: $editedBody) {
                Task {
                    print("\(comment.id)")
                    do {
                        let updated = try await APIService.shared.updateComment(
                            commentId: comment.id,
                            body: editedBody
                        )
                        onUpdate(updated) // 🔥 send it up instead
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func reactionButton(label: String, active: Bool, activeColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(active ? activeColor.opacity(0.12) : Color(.systemGray6))
                .foregroundColor(active ? activeColor : .primary)
                .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }

    func likeComment() async {
        let snap = comment
        if comment.likedBy.contains(userId) { comment.likedBy.removeAll { $0 == userId } }
        else { comment.likedBy.append(userId); comment.dislikedBy.removeAll { $0 == userId } }
        do { comment = try await APIService.shared.likeComment(commentId: comment.id, userId: userId) }
        catch { comment = snap }
    }

    func dislikeComment() async {
        let snap = comment
        if comment.dislikedBy.contains(userId) { comment.dislikedBy.removeAll { $0 == userId } }
        else { comment.dislikedBy.append(userId); comment.likedBy.removeAll { $0 == userId } }
        do { comment = try await APIService.shared.dislikeComment(commentId: comment.id, userId: userId) }
        catch { comment = snap }
    }
}

// MARK: - Inline edit sheet
struct EditCommentSheet: View {
    @Binding var mainContent: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var swiftBody: some View {  // avoid 'body' naming conflict
        NavigationStack {
            TextEditor(text: $mainContent)
                .padding()
                .navigationTitle("Edit Comment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { Task {onSave(); await MainActor.run {dismiss() }}}
                            .fontWeight(.semibold)
                            .disabled(mainContent.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
        }
        .presentationDetents([.medium])
    }

    var body: some View { swiftBody }
}
