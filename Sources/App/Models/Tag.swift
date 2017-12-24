import FluentProvider

final class Tag: Model {
    let storage = Storage()
    
    var title: String
    
    struct Keys {
        static let id = "id"
        static let title = "title"
        static let content = "content"
    }
    
    init(title: String) {
        self.title = title
    }
    
    init(row: Row) throws {
        self.title = try row.get(Tag.Keys.title)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Tag.Keys.title, title)
        return row
    }
}

extension Tag: ViewDataRepresentable {
    public func makeViewData() throws -> ViewData {
        return try ViewData(viewData: [
            "id": .number(.int(id?.int ?? 0)),
            "title": .string(title)
            ])
    }
}

extension Tag: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return try Node([
            "id": Node.number(.int(id?.int ?? 0)),
            "title": .string(title)
            ])
    }
}

extension Tag: Timestampable {}
extension Tag: SoftDeletable {}
extension Tag: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Tag.Keys.title)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


// Convenience of generate model from JSON
extension Tag: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(title: try json.get(Tag.Keys.title))
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Tag.idKey, id?.string)
        try json.set(Tag.Keys.title, title)
        try json.set("postCount", self.postCount())
        return json
    }
}

extension Tag: ResponseRepresentable {}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Tag: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Tag>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Tag.Keys.title, String.self) { tag, title in
                tag.title = title
            }
        ]
    }
}

extension Tag {
    func posts() throws -> [Post] {
        let posts: Siblings<Tag, Post, Pivot<Tag, Post>> = siblings()
        return try posts.all()
    }
    func postCount() throws -> Int {
        return try self.posts().count
    }
}
