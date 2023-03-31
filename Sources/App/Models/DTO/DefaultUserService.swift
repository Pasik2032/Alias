import JWT
import Vapor

func signIn(request: Request, user: User) throws -> Future<AccessDto> {
    return User
        .query(on: request)
        .filter(\.login == user.login)
        .first()
        .unwrap(or: Abort(.badRequest, reason: "User with login \(user.login) not found"))
        .flatMap { persistedUser in
            let digest = try request.make(BCryptDigest.self)
            
            if try digest.verify(user.password, created: persistedUser.password) {
                let accessToken = try TokenHelpers.createAccessToken(from: persistedUser)
                let expiredAt = try TokenHelpers.expiredDate(of: accessToken)
                let accessDto = AccessDto(accessToken: accessToken, expiredAt: expiredAt)
                
                return request.future(accessDto)
            } else {
                throw Abort(.badRequest, reason: "Incorrect user password")
            }
    }
}
