import JWT
import Vapor
import Fluent

struct TodoDto: Content {
    
    let id: Int?
    let title: String
}
