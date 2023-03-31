import Vapor

protocol TodoService {
    
    func create(request: Request, todoDto: TodoDto) throws -> Future<TodoDto>
    func fetch(request: Request) throws -> Future<[TodoDto]>
    func delete(request: Request, todoID: Int) throws -> Future<TodoDto>
}
