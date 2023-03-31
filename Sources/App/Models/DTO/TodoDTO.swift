import JWT
import Vapor
import Fluent
import FluentSQLiteDriver

struct TodoDto: Content {
    
    let id: Int?
    let title: String
}
