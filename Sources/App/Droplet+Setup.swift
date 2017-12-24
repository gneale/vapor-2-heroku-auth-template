@_exported import Vapor
import PostgreSQLProvider

weak var drop: Droplet!

extension Droplet {
    public func setup() throws {
        drop = self
        try setupRoutes()
        seedData()
    }
    
    func seedData() {
        //################ NOTES ################
        // 
        
        guard (try? User.count()) == 0 else { return }
        
        let u1 = try? User.register(username: "gneale@mac.com", password: "password")
        let u2 = try? User.register(username: "kiki@mac.com", password: "password")
        let u3 = try? User.register(username: "u3", password: "123")
        let u4 = try? User.register(username: "u4", password: "123")
        
        if let u1Id = u1?.id { let t1 = AccessToken(token: "grantstoken", userId: u1Id); try? t1.save() }
        if let u2Id = u2?.id { let t2 = AccessToken(token: "kikistoken", userId: u2Id); try? t2.save() }
        if let u3Id = u3?.id { let t3 = AccessToken(token: "u3 token", userId: u3Id); try? t3.save() }
        if let u4Id = u4?.id { let t4 = AccessToken(token: "u4 token", userId: u4Id); try? t4.save() }
        
        let news = try? Tag.init(title: "News")
        try? news?.save()
        let happening = try? Tag.init(title: "Happening")
        try? happening?.save()

        let post1 = try? Post.init(title: "A new day in Dordogne", content: "lots of new day in the dordogne", published: false)

        try? post1?.tags.add(news!)
        
        let post2 = try? Post.init(title: "The best day in Dordogne", content: "lots of best day in the dordogne", published: false)
        
        try? post2?.tags.add(happening!)
    }
}
