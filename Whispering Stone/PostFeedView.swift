import SwiftUI

struct PostFeedView: View {
    let userId: String
    @StateObject private var vm = PostViewModel()

    var body: some View {
        List {
            ForEach(Array(vm.posts.enumerated()), id: \.element.id) { index, post in
                VStack(alignment: .leading, spacing: 8) {
                    NavigationLink(
                        destination: PostDetailView(
                            post: $vm.posts[index],
                            userId: userId,
                            onLike: { await vm.like(post: vm.posts[index], userId: userId) },
                            onDislike: { await vm.dislike(post: vm.posts[index], userId: userId) }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(post.title ?? "No title")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(post.body)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)

                            Text("by \(post.authorName ?? "Unknown")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 16) {
                        Button {
                            Task { await vm.like(post: post, userId: userId) }
                        } label: {
                            Text(post.likedBy.contains(userId) ? "👍 \(post.likeCount)" : "🤍 \(post.likeCount)")
                                .font(.subheadline)
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { await vm.dislike(post: post, userId: userId) }
                        } label: {
                            Text(post.dislikedBy.contains(userId) ? "👎 \(post.dislikeCount)" : "🖤 \(post.dislikeCount)")
                                .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Whispering Stone")
        .onAppear {
            Task { await vm.fetchPosts(userId: userId) }
        }
    }
}
