//
//  CreateWaitRoom.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import FluentKit

struct CreateWaitRoom: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(WaitRoom.schema)
      .id()
      .field("name", .string, .required)
      .unique(on: "name")
      .field("admin_id",  .uuid, .references("users", .id))
      .field("code", .int16)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(WaitRoom.schema).delete()
  }
}
