import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let title: String?
    let body: String
    let authorId: String
    let authorName: String?
    let tag: String?
    var likedBy: [String]
    var dislikedBy: [String]
    let createdAt: String?

    var likeCount: Int { likedBy.count }
    var dislikeCount: Int { dislikedBy.count }

    var timeAgo: String {
        guard let createdAt else { return "" }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: createdAt) else { return "" }
        let diff = Date().timeIntervalSince(date)
        switch diff {
        case ..<60:     return "Just now"
        case ..<3600:   return "\(Int(diff / 60)) min ago"
        case ..<86400:  return "\(Int(diff / 3600)) hr ago"
        case ..<604800: return "\(Int(diff / 86400)) days ago"
        default:
            let d = DateFormatter(); d.dateStyle = .short
            return d.string(from: date)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, body, authorId, authorName, tag, likedBy, dislikedBy, createdAt
    }
}
