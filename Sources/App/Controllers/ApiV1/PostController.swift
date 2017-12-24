import Vapor
import HTTP
import FluentProvider
import JSONAPISerializer

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class PostController: ResourceRepresentable {

    
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    fileprivate func index(req: Request) throws -> ResponseRepresentable {
        
        let config = JSONAPIConfig(type: "posts")
        let serializer = JSONAPISerializer(config: config)

        let posts = try Post.all()
//        let serialized_posts = try serializer.serialize(posts)
//        return try JSON(node: ["posts": [serialized_posts]])
        return try serializer.serialize(posts)
    }
    
    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    fileprivate func store(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.post()
        try post.save()
        
        let config = JSONAPIConfig(type: "posts")
        let serializer = JSONAPISerializer(config: config)
        return try serializer.serialize(post)
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    fileprivate func show(_ req: Request, post: Post) throws -> ResponseRepresentable {
        let config = JSONAPIConfig(type: "posts")
        let serializer = JSONAPISerializer(config: config)
        return try serializer.serialize(post)
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    fileprivate func delete(_ req: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
//    fileprivate func clear(_ req: Request) throws -> ResponseRepresentable {
//        try Post.makeQuery().delete()
//        return Response(status: .ok)
//    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    fileprivate func update(_ req: Request, post: Post) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try post.update(for: req)
        
        // Save an return the updated post.
        try post.save()
        
        let config = JSONAPIConfig(type: "posts")
        let serializer = JSONAPISerializer(config: config)
        return try serializer.serialize(post)
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    fileprivate func replace(_ req: Request, post: Post) throws -> ResponseRepresentable {
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.post()
        
        // Update the post with all of the properties from
        // the new post
        post.content = new.content
        try post.save()
        
        // Return the updated post
        let config = JSONAPIConfig(type: "posts")
        let serializer = JSONAPISerializer(config: config)
        return try serializer.serialize(post)
    }
    
    func addRoutes(_ drop: Droplet) {
        let postsGroup = drop.grouped("api/v1/posts")
        postsGroup.post(Post.parameter, "tags", Tag.parameter, handler: addTag)
    }
    
    func addTag(req: Request) throws -> ResponseRepresentable {
        let post = try req.parameters.next(Post.self)
        let tag = try req.parameters.next(Tag.self)
        let pivot = try Pivot<Post, Tag>(post, tag)
        let existingRelation = try pivot.makeQuery().filter("post_id", post.id).filter("tag_id", tag.id).all()
        
        if existingRelation.count == 0 {
            try pivot.save()
        } else {
            throw Abort(.badRequest, reason: "This tag has already been added")
        }
        
        let config = JSONAPIConfig(type: "posts")
        let serializer = JSONAPISerializer(config: config)
        return try serializer.serialize(post)
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete//,
//            clear: clear
        )
    }
}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        return try Post(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension PostController: EmptyInitializable { }

