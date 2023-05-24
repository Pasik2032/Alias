//
//  CreateTeam.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import FluentKit

struct CreateTeam: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(RoomTeam.schema)
      .id()
      .field("room", .uuid, .references("WaitRoom", .id))
      .field("color", .string, .required)
      .unique(on: "color")
      .field("point", .int16)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(RoomTeam.schema).delete()
  }
}
