//
//  CreatePlayer.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import FluentKit

struct CreatePlayer: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Player.schema)
      .id()
      .field("team", .uuid, .references("Team", .id))
      .field("user", .uuid, .references("users", .id))
      .field("isReady", .bool)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Player.schema).delete()
  }
}
