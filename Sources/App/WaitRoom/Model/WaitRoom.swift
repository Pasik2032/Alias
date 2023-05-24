//
//  WaitRoom.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import Vapor
import FluentKit

final class WaitRoom: Model {

  struct Public: Content {
    let name: String
    let teamsCount: Int
  }

  func asPublic(db: Database) async -> Public {
    let count = await (try? $teams.get(on: db).count) ?? 0
    return Public(name: name, teamsCount: count)
  }

  struct DetailModel: Content {
    let id: UUID
    let name: String
    var isAdmin: Bool?
    let code: Int?
    let teams: [RoomTeam.Public]
  }

  func asDetail(db: Database) async -> DetailModel {
    let teams = await (try? $teams.get(on: db)) ?? []
    var teamsDTO: [RoomTeam.Public] = []
    for team in teams {
      teamsDTO.append(await team.asPublic(db: db))
    }
    return DetailModel(
      id: id!,
      name: name,
      isAdmin: nil,
      code: code,
      teams: teamsDTO
    )
  }

  init() {
    
  }

  static var schema: String = "WaitRoom"

  @ID
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Parent(key: "admin_id")
  var admin: User

  @OptionalField(key: "code")
  var code: Int?

  var isOpen: Bool { code == nil }

  @Children(for: \.$room)
  var teams: [RoomTeam]

  init(id: UUID? = nil, name: String, admin: User, code: Int? = nil, teams: [RoomTeam]) {
    self.id = id
    self.name = name
    self.admin = admin
    self.code = code
    self.teams = teams
  }

  init(adminId: User.IDValue, dto: CreateRoomDTO) {
    self.name = dto.name
    self.$admin.id = adminId
    self.code = dto.isPrivate ? Int.random(in: 1000...9999) : nil
  }

  static func create(adminId: User.IDValue, dto: CreateRoomDTO) {
    let room = WaitRoom(adminId: adminId, dto: dto)

  }
}
