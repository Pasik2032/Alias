import Vapor
import Fluent
import FluentSQLiteDriver
import JWT

final class UserController {
    
    fileprivate var userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func signUp(_ request: Request, user: User) throws -> Future<ResponseDto> {
        return try self.userService.signUp(request: request, user: user)
    }
    
    func signIn(_ request: Request, user: User) throws -> Future<HTTPResponseStatus> {
        return request.future(.notImplemented)
    }
}

extension UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("v1/account")
        
        group.post(User.self, at: "/sign-up", use: self.signUp)
        group.post(User.self, at: "/sign-in", use: self.signIn)
    }
}
