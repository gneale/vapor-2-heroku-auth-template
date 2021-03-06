import Vapor
import HTTP
import FluentProvider
import JSONAPISerializer

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class TagController: ResourceRepresentable {
    
    
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(req: Request) throws -> ResponseRepresentable {
        
        let config = JSONAPIConfig(type: "tags")
        let serializer = JSONAPISerializer(config: config)
        
        let tags = try Tag.all()
        //        let serialized_posts = try serializer.serialize(posts)
        //        return try JSON(node: ["posts": [serialized_posts]])
        return try serializer.serialize(tags)
    }
    
    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let tag = try req.tag()
        try tag.save()
        return tag
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(_ req: Request, tag: Tag) throws -> ResponseRepresentable {
        return tag
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, tag: Tag) throws -> ResponseRepresentable {
        try tag.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Tag.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, tag: Tag) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try tag.update(for: req)
        
        // Save an return the updated post.
        try tag.save()
        return tag
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    func replace(_ req: Request, tag: Tag) throws -> ResponseRepresentable {
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.tag()
        
        // Update the post with all of the properties from
        // the new post
        tag.title = new.title
        try tag.save()
        
        // Return the updated post
        return tag
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Tag> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func tag() throws -> Tag {
        guard let json = json else { throw Abort.badRequest }
        return try Tag(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension TagController: EmptyInitializable { }


