//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 20.05.2023.
//

import Fluent

// 1
struct CreateUsers: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(User.schema)
      .id()
      .field("username", .string, .required)
      .unique(on: "username")
      .field("password_hash", .string, .required)
      .field("created_at", .datetime, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(User.schema).delete()
  }
}
