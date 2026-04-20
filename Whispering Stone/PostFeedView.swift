import SwiftUI
import ClerkKit
import ClerkKitUI

struct PostFeedView: View {
    let userId: String
    @StateObject private var vm = PostViewModel()
    @State private var showCreate = false
    @Environment(Clerk.self) private var clerk

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(Array(vm.posts.enumerated()), id: \.element.id) { index, post in
                    NavigationLink(destination: PostDetailView(
                        post: $vm.posts[index],
                        userId: userId
                    )
                    .environmentObject(vm)
                    ) {
                        PostCardView(post: post, userId: userId)
                    }
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))

            // FAB
            Button { showCreate = true } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .blue.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Whispering Stone")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { UserButton() }
        }
        .onAppear { Task { await vm.fetchPosts(userId: userId) } }
        .sheet(isPresented: $showCreate) {
            let name = [clerk.user?.firstName, clerk.user?.lastName]
                .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
            CreatePostView(userId: userId, authorName: name)
                .environmentObject(vm)
        }
    }
}

// MARK: - Post Card
struct PostCardView: View {
    let post: Post
    let userId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let tag = post.tag, !tag.isEmpty {
                Text(tag)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }

            Text(post.title ?? "Untitled")
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(post.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            HStack(spacing: 6) {
                AvatarView(name: post.authorName, size: 22)
                Text(post.authorName ?? "Unknown")
                    .font(.caption).foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(post.likedBy.contains(userId) ? "👍" : "🤍")
                Text("\(post.likeCount)").font(.caption).foregroundColor(.secondary)
                Text(post.dislikedBy.contains(userId) ? "👎" : "🖤")
                Text("\(post.dislikeCount)").font(.caption).foregroundColor(.secondary)
                Text(post.timeAgo).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
