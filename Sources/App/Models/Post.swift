import Vapor
import FluentProvider
import HTTP

final class Post: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var title: String
    var content: String
    var published: Bool
    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let title = "title"
        static let content = "content"
        static let published = "published"
    }
    
    /// Creates a new Post
    init(title: String, content: String, published: Bool) {
        self.title = title
        self.content = content
        self.published = published
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        title = try row.get(Post.Keys.title)
        content = try row.get(Post.Keys.content)
        published = try row.get(Post.Keys.published)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.Keys.title, title)
        try row.set(Post.Keys.content, content)
        try row.set(Post.Keys.published, published)
        return row
    }
}

extension Post: ViewDataRepresentable {
    public func makeViewData() throws -> ViewData {
        return try ViewData(viewData: [
            "id": .number(.int(id?.int ?? 0)),
            "title": .string(title),
            "content": .string(content),
            "published": .bool(published)
            ])
    }
}

extension Post: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return try Node([
            "id": Node.number(.int(id?.int ?? 0)),
            "title": .string(title),
            "content": .string(content),
            "published": .bool(published)
            ])
    }
}


// MARK: Fluent Preparation
extension Post: Timestampable {}
extension Post: SoftDeletable {}
extension Post: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Post.Keys.title)
            builder.string(Post.Keys.content)
            builder.string(Post.Keys.published)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Post: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            title: json.get(Post.Keys.title),
            content: json.get(Post.Keys.content),
            published: json.get(Post.Keys.published)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Post.Keys.id, id)
        try json.set(Post.Keys.title, title)
        try json.set(Post.Keys.content, content)
        try json.set(Post.Keys.published, published)
        try json.set("tags", self.tags.all())
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Post: ResponseRepresentable {}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Post: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Post>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Post.Keys.content, String.self) { post, content in
                post.content = content
            },
            UpdateableKey(Post.Keys.title, String.self) {post, title in
                post.title = title
            },
            UpdateableKey(Post.Keys.published, Bool.self) {post, published in
                post.published = published
            }
        ]
    }
}

extension Post {
    var tags: Siblings<Post, Tag, Pivot<Post, Tag>> {
        return siblings()
    }
//    func tags() throws -> [Tag] {
//        let tags: Siblings<Post, Tag, Pivot<Post, Tag>> = siblings()
//        return try tags.all()
//    }
}
