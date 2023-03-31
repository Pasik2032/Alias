//import Fluent
//import Vapor
//
//func routes(_ app: Application) throws {
//    app.get { req async in
//        "It works!"
//    }
//
//    app.get("hello") { req async -> String in
//        "Hello, world1111111!"
//    }
//
//    try app.register(collection: TodoController())
//}

import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // MARK: - TodoController
    
    let todoController = TodoController(todoService: ProjectServices.todoService)
    
    try router.register(collection: todoController)
    
    // MARK: - UserController
    
    let userController = UserController(userService: ProjectServices.userService)
    
    try router.register(collection: userController)
}
