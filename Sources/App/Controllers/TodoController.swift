//import Fluent
//import Vapor
//
//struct TodoController: RouteCollection {
//    func boot(routes: RoutesBuilder) throws {
//        let todos = routes.grouped("todos")
//        todos.get(use: index)
//        todos.post(use: create)
//        todos.group(":todoID") { todo in
//            todo.delete(use: delete)
//        }
//    }
//
//    func index(req: Request) async throws -> [Todo] {
//        try await Todo.query(on: req.db).all()
//    }
//
//    func create(req: Request) async throws -> Todo {
//        let todo = try req.content.decode(Todo.self)
//        try await todo.save(on: req.db)
//        return todo
//    }
//
//    func delete(req: Request) async throws -> HTTPStatus {
//        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        try await todo.delete(on: req.db)
//        return .noContent
//    }
//}

import Vapor

final class TodoController {
    
    fileprivate var todoService: TodoService
    
    init(todoService: TodoService) {
        self.todoService = todoService
    }
    
    func fetch(_ req: Request) throws -> Future<[TodoDto]> {
        return try self.todoService.fetch(request: req)
    }

    func create(_ req: Request, todoDto: TodoDto) throws -> Future<TodoDto> {
        return try self.todoService.create(request: req, todoDto: todoDto)
    }

    func delete(_ req: Request) throws -> Future<TodoDto> {
        let todoID = try req.parameters.next(Int.self)
        return try self.todoService.delete(request: req, todoID: todoID)
    }
}

extension TodoController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("v1/todo").grouped(JWTMiddleware())
        
        group.post(TodoDto.self, use: self.create)
        group.get(use: self.fetch)
        group.delete(Int.parameter, use: self.delete)
    }
}
