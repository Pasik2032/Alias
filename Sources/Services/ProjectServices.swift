import Vapor
import Fluent
//import FluentSQLite
import JWT
import FluentSQLiteDriver

enum ProjectServices {
    
    static let userService: UserService = DefaultUserService()
    static let todoService: TodoService = DefaultTodoService()
}
