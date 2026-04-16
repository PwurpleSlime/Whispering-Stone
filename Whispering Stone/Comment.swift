struct Comment: Codable, Identifiable {
    let id: String
    let postId: String
    let authorId: String
    let authorName: String
    let body: String
    var likedBy: [String]
    var dislikedBy: [String]

    var likeCount: Int { likedBy.count }
    var dislikeCount: Int { dislikedBy.count }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case postId
        case authorId
        case authorName
        case body
        case likedBy
        case dislikedBy
    }
}
