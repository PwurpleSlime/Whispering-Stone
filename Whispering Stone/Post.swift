struct Post: Codable, Identifiable {
    let id: String
    let title: String?
    let body: String
    let authorId: String
    let authorName: String?
    var likedBy: [String]
    var dislikedBy: [String]

    // ✅ Always derived, never stored or decoded separately
    var likeCount: Int { likedBy.count }
    var dislikeCount: Int { dislikedBy.count }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case body
        case authorId
        case authorName
        case likedBy
        case dislikedBy
        // ✅ likeCount and dislikeCount intentionally excluded
    }
}
