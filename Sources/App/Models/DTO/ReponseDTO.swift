import JWT
import Vapor
import Fluent
import FluentSQLiteDriver

struct ResponseDto: Content {
    
    let message: String
}
