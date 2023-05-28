//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import Vapor
import FluentKit


struct ChangeTeamDTO: Content {
  let uuid: UUID
}

struct CodeDTO: Content {
  let code: Int
}

struct WaitRoomController: RouteCollection {
  func boot(routes: Vapor.RoutesBuilder) throws {
    let waitRoomRoute = routes.grouped("room").grouped(Token.authenticator())
    waitRoomRoute.post("create", use: create)
    waitRoomRoute.get(":id", use: getRoom)
    waitRoomRoute.get("open", use: getOpenRooms)
    waitRoomRoute.post("add", use: addRoomCode)
    waitRoomRoute.post(":id", "add", use: addRoom)
    waitRoomRoute.post(":id", "addTeam", use: addTeam)
    waitRoomRoute.post(":id", "deleteTeam", use: deleteTeam)
    waitRoomRoute.post(":id", "team", "change", use: teamChangeTeam)
    waitRoomRoute.post(":id", "exit", use: exitRoom)
    waitRoomRoute.post(":id", "aprove", use: aproveGame)
  }

  func aproveGame(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard
      let id = req.parameters.get("id", as: UUID.self),
      let room = try await WaitRoom.find(id, on: req.db)
    else {
      throw Abort(.badRequest)
    }
    let players = try? await Player.query(on: req.db).all()
    for player in players! {
      let a = (try? await player.$user.get(on: req.db))!
      let b = try a.requireID()
      let c = try user.requireID()
      if b == c {
        player.isReady = true
        try? await player.update(on: req.db)
        break
      }
    }

//    let u = try? await room.$admin.get(on: req.db)
//    if u?.id == user.$id.value {
//      room.
//    }



    let newModel = try await getDetailRoom(uuid: id, db: req.db, user: user)
    if
      let str = try? JSONEncoder().encode(newModel),
      let json = String(data: str, encoding: String.Encoding.utf8)
    {
      SocketUser.wsRoomsSub[id]?.forEach { $0.ws.send(json) }
    }

    return newModel
  }

  func exitRoom(req: Request) async throws -> String {
    let user = try req.auth.require(User.self)

    let players = try? await Player.query(on: req.db).all()
    for player in players! {
      let a = (try? await player.$user.get(on: req.db))!
      let b = try a.requireID()
      let c = try user.requireID()
      if b == c {
        try await player.delete(on: req.db)
        return "OK"
      }
    }

    throw Abort(.badRequest)
  }

  func addRoomCode(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard let model = try? req.content.decode(CodeDTO.self) else {
      throw Abort(.badRequest)
    }
    guard let room = try? await WaitRoom.query(on: req.db)
      .filter(\.$code == model.code)
      .first()
    else {
      throw Abort(.badRequest)
    }


    let teams = try? await room.$teams.get(on: req.db).first

    let player = Player(team: try! teams!.requireID(), user:  try! user.requireID())
    try await player.save(on: req.db)


    return try await getDetailRoom(uuid: room.requireID(), db: req.db, user: user)
  }

  func deleteTeam(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard
      let id = req.parameters.get("id", as: UUID.self),
      let room = try await WaitRoom.find(id, on: req.db),
      let model = try? req.content.decode(ChangeTeamDTO.self),
      let deleteTeam = try await RoomTeam.find(model.uuid, on: req.db)
    else {
      throw Abort(.badRequest)
    }
    let u = try? await room.$admin.get(on: req.db)
    guard u?.id == user.$id.value else {
      throw Abort(.badRequest)
    }
    let users = (try? await deleteTeam.$user.get(on: req.db)) ?? []

    if users.isEmpty {
      try await deleteTeam.delete(on: req.db)
      let newModel = try await getDetailRoom(uuid: id, db: req.db, user: user)
      if
        let str = try? JSONEncoder().encode(newModel),
        let json = String(data: str, encoding: String.Encoding.utf8)
      {
        SocketUser.wsRoomsSub[id]?.forEach { $0.ws.send(json) }
      }

      return newModel
    } else {
      throw Abort(.badRequest)
    }
  }

  func addTeam(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard
      let id = req.parameters.get("id", as: UUID.self),
      let room = try await WaitRoom.find(id, on: req.db)
    else {
      throw Abort(.badRequest)
    }
    let u = try? await room.$admin.get(on: req.db)
    guard u?.id == user.$id.value else {
      throw Abort(.badRequest)
    }

    let team = RoomTeam.create()
    try await room.$teams.create([team], on: req.db)

    let newModel =  try await getDetailRoom(uuid: id, db: req.db, user: user)
    if
      let str = try? JSONEncoder().encode(newModel),
      let json = String(data: str, encoding: String.Encoding.utf8)
    {
      SocketUser.wsRoomsSub[id]?.forEach { $0.ws.send(json) }
    }
    return newModel
  }

  func teamChangeTeam(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard
      let id = req.parameters.get("id", as: UUID.self),
      let room = try await WaitRoom.find(id, on: req.db),
      let model = try? req.content.decode(ChangeTeamDTO.self)
    else {
      throw Abort(.badRequest)
    }
    let teams = try await room.$teams.get(on: req.db)
    var myPlayer: Player?
    for team in teams {
      let players = try await team.$user.get(on: req.db)
      for player in players {
        let us = try await player.$user.get(on: req.db)
        let a =  try us.requireID()
        let b =  try user.requireID()
        if a == b {
          myPlayer = player
          break
        }
      }
    }
    let newPlaye = Player(team: model.uuid, user: try user.requireID())
    try? await newPlaye.save(on: req.db)
    try? await myPlayer?.delete(on: req.db)

    let newModel = try await getDetailRoom(uuid: id, db: req.db, user: user)
    if
      let str = try? JSONEncoder().encode(newModel),
      let json = String(data: str, encoding: String.Encoding.utf8)
    {
      SocketUser.wsRoomsSub[id]?.forEach { $0.ws.send(json) }
    }

    return newModel
  }


  func addRoom(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard
      let id = req.parameters.get("id", as: UUID.self),
      let room = try await WaitRoom.find(id, on: req.db)
    else {
      throw Abort(.badRequest)
    }

    let teams = try? await room.$teams.get(on: req.db).first

    let player = Player(team: try! teams!.requireID(), user:  try! user.requireID())
    try await player.save(on: req.db)


    let newModel = try await getDetailRoom(uuid: id, db: req.db, user: user)
    if
      let str = try? JSONEncoder().encode(newModel),
      let json = String(data: str, encoding: String.Encoding.utf8)
    {
      SocketUser.wsRoomsSub[id]?.forEach { $0.ws.send(json) }
    }

    return newModel
  }

  func getOpenRooms(req: Request) async throws -> [WaitRoom.Public] {
    let rooms = (try? await WaitRoom.query(on: req.db).all()) ?? []
    let openRooms = rooms.filter { $0.isOpen }

    var result: [WaitRoom.Public] = []
    for room in openRooms {
      await result.append(room.asPublic(db: req.db))
    }
    return result
  }

  func getRoom(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    guard let id = req.parameters.get("id", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    let room = try await WaitRoom.find(id, on: req.db)
    var dto = await room?.asDetail(db: req.db)
    let u = try? await room?.$admin.get(on: req.db)
    dto?.isAdmin = (u?.id == user.$id.value)
    if let dto {
      return dto
    } else {
      throw Abort(.badRequest)
    }
  }

  func create(req: Request) async throws -> WaitRoom.DetailModel {
    let user = try req.auth.require(User.self)
    let model = try req.content.decode(CreateRoomDTO.self)

    let room = WaitRoom(adminId: try! user.requireID(), dto: model)
    let team = RoomTeam.create()

    try await room.save(on: req.db)
    try await room.$teams.create([team], on: req.db)


    let player = Player(team: try! team.requireID(), user:  try! user.requireID())
    try await player.save(on: req.db)
    var dto = await room.asDetail(db: req.db)
    dto.isAdmin = true

    let all = try? await getOpenRooms(req: req)
    SocketUser.wsAllRooms.forEach {

      if
        let str = try? JSONEncoder().encode(all),
        let json = String(data: str, encoding: String.Encoding.utf8)
      {
        $0.ws.send(json)
      }
    }
    return dto
  }

  private func getDetailRoom(uuid: UUID, db: Database, user: User) async throws -> WaitRoom.DetailModel {
    let room = try? await WaitRoom.find(uuid, on: db)
    var dto = await room?.asDetail(db: db)
    let u = try? await room?.$admin.get(on: db)
    dto?.isAdmin = (u?.id == user.$id.value)
    if let dto {
      return dto
    } else {
      throw Abort(.badRequest)
    }
  }
}
