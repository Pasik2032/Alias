//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 06.04.2023.
//

import Foundation
import JWTKit
import Vapor

struct User: JWTPayload {

  static var users: [User] = []

  let name: String
  let password: String
  let login: String

  // The "exp" (expiration time) claim identifies the expiration time on
  // or after which the JWT MUST NOT be accepted for processing.
  var expiration: ExpirationClaim


  func verify(using signer: JWTKit.JWTSigner) throws {
    try self.expiration.verifyNotExpired()
  }
}

struct UserModel: Content {
  let name: String
}
