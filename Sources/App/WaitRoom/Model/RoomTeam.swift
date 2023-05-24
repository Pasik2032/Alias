//
//  RoomTeam.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import Vapor
import FluentKit

final class RoomTeam: Model {

  struct Public: Content {
    var id: UUID
    var color: String
    var point: Int
    var user: [Player.Public]
  }

  func asPublic(db: Database) async -> Public {
    let users = await (try? $user.get(on: db)) ?? []
    var userDTO: [Player.Public] = []
    for user in users {
      userDTO.append(await user.asPublic(db: db))
    }
    return Public(
      id: id!,
      color: color,
      point: point,
      user: userDTO
    )
  }


  init() {
    
  }

  static var schema: String = "Team"

  @ID
  var id: UUID?

  @Parent(key: "room")
  var room: WaitRoom

  @Field(key: "color")
  var color: String

  @Field(key: "point")
  var point: Int

  @Children(for: \.$team)
  var user: [Player]

  init(id: UUID? = nil, room: WaitRoom, color: String, point: Int, user: [Player]) {
    self.id = id
    self.room = room
    self.color = color
    self.point = point
    self.user = user
  }

  static func create() -> RoomTeam {
    var team = RoomTeam()
    var baseIntA = Int(arc4random() % 65535)
    var baseIntB = Int(arc4random() % 65535)
    team.color = String(format: "%06X", baseIntA, baseIntB)
    team.point = 0
    return team
  }
}

final class Player: Model {

  struct Public: Content {
    let name: String
    let id: UUID
    let isReady: Bool
  }

  func asPublic(db: Database) async -> Public {
    let name = await (try? $user.get(on: db))?.username
    return Public(name: name ?? "", id: id!, isReady: isReady)
  }

  init() {
  }

  static var schema: String = "Player"

  @ID
  var id: UUID?

  @Parent(key: "team")
  var team: RoomTeam

  @Parent(key: "user")
  var user: User

  @Field(key: "isReady")
  var isReady: Bool

  init(id: UUID? = nil, team: RoomTeam, user: User, isReady: Bool ) {
    self.id = id
    self.team = team
    self.user = user
    self.isReady = isReady
  }

  init(team: RoomTeam.IDValue, user: User.IDValue) {
    self.$team.id = team
    self.$user.id = user
    self.isReady = false
  }
}
