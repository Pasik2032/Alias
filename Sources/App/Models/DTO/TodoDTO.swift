import Vapor

struct TodoDto: Content {
    
    let id: Int?
    let title: String
}
