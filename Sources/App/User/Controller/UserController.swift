//
//  UserController.swift
//  
//
//  Created by Даниил Пасилецкий on 20.05.2023.
//

import Foundation
import Vapor
import Fluent

struct UserSignup: Content {
  let username: String
  let password: String
}

struct NewSession: Content {
  let token: String
  let user: User.Public
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}
extension Validatable {
  public static func validate(_ request: Request) throws {
    try self.validations().validate(request: request).assert()
  }

  public static func validate(json: String) throws {
    try self.validations().validate(json: json).assert()
  }

  public static func validate(_ decoder: Decoder) throws {
    try self.validations().validate(decoder).assert()
  }

  public static func validations() -> Validations {
    var validations = Validations()
    self.validations(&validations)
    return validations
  }
}

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("users")
    usersRoute.post("signup", use: create)

    let tokenProtected = usersRoute.grouped(Token.authenticator())
    tokenProtected.get("me", use: getMyOwnUser)

    let passwordProtected = usersRoute.grouped(User.authenticator())
    passwordProtected.post("login", use: login)

  }

  fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
    try UserSignup.validate(req)
    let userSignup = try req.content.decode(UserSignup.self)
    let user = try User.create(from: userSignup)
    var token: Token!


    return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
      guard !exists else {
        return req.eventLoop.future(error: UserError.usernameTaken)
      }

      return user.save(on: req.db)
    }.flatMap {
      guard let newToken = try? user.createToken(source: .signup) else {
        return req.eventLoop.future(error: Abort(.internalServerError))
      }
      token = newToken
      return token.save(on: req.db)
    }.flatMapThrowing {
      NewSession(token: token.value, user: try user.asPublic())
    }
  }

  fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
    // 1
    let user = try req.auth.require(User.self)
    // 2
    let token = try user.createToken(source: .login)

    return token
      .save(on: req.db)
      .flatMapThrowing {
        NewSession(token: token.value, user: try user.asPublic())
      }
  }

  func getMyOwnUser(req: Request) throws -> User.Public {
    try req.auth.require(User.self).asPublic()
  }

  private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
    User.query(on: req.db)
      .filter(\.$username == username)
      .first()
      .map { $0 != nil }
  }
}


enum UserError {
  case usernameTaken
}

extension UserError: AbortError {
  var description: String {
    reason
  }

  var status: HTTPResponseStatus {
    switch self {
    case .usernameTaken: return .conflict
    }
  }

  var reason: String {
    switch self {
    case .usernameTaken: return "Username already taken"
    }
  }
}
