//
//  File 2.swift
//  
//
//  Created by Даниил Пасилецкий on 06.04.2023.
//

import Foundation

class Player: Equatable {
  static func == (lhs: Player, rhs: Player) -> Bool {
    lhs.login == rhs.login
  }
  static var players: [Player] = []
  static func find(_ user: User) -> Player? {
    players.first { $0.login == user.login }
  }
  static func find(name: String) -> Player? {
    Player.players.first { $0.name == name }
  }


  var dto: UserModel {
    UserModel(name: name)
  }


  let name: String
  let login: String
  let password: String

  init(user: User) {
    self.name = user.name
    self.login = user.login
    self.password = user.password
  }

  init(login: String, name: String, password: String) {
    self.name = name
    self.login = login
    self.password = password
  }
}




class TeamPlayer {

  var dto: Team {
    Team(
      id: number,
      players: players.map { $0.dto },
      points: point
    )
  }

  var isValid: Bool {
    !players.isEmpty
  }

  var number: Int
  var players: [Player]
  var point: Int

  var currentPlayer: Int = -1

  var current: Player {
    players[currentPlayer]
  }

  init(number: Int) {
    self.number = number
    self.players = []
    self.point = 0
    self.currentPlayer = 0
  }

  func update() -> Player {
    currentPlayer = (currentPlayer + 1) % players.count
    return current
  }
}

class Game {
  static var games: [Game] = []
  static var id: Int = 0

  static func delete(model: Game) {
    Game.games.removeAll { $0.id == model.id}
  }

  static func find(id: Int) -> Game {
    Game.games.first { $0.id == id }!
  }


  func newAdmin(name: String) {
    let playe = Player.find(name: name)
    admin = playe!
  }

  func join(player: Player) {
    waits.append(player)
  }

  func updateSetting(model: Setting) {
    secondRound = Double(model.timeRound)
    pointK = model.poin
  }


  var dto: Room {
    Room(
      name: name,
      id: id,
      isOpen: isOpen,
      code: code,
      admin: admin.dto,
      teams: teams.map { $0.dto },
      wait: waits.map { $0.dto },
      start: isStart,
      setting: Setting(
        timeRound: Int(secondRound),
        poin: pointK
      )
    )
  }

  var id: Int

  var name: String

  var currentTeam: Int = -1

  var curentPlayer: Player? = nil

  var teams: [TeamPlayer]
  var waits: [Player]
  var admin: Player

  var isOpen: Bool
  var isStart: Bool = false

  var isVisibel: Bool {
    isStart && isOpen
  }

  var code: Int

  var pointK: Int = 1
  var secondRound: Double = 30.0

  var isTeams: Bool {
    !teams.isEmpty
  }


  func createTeam() {
    teams.append(TeamPlayer(number: teams.count))
  }

  func selectTeam(player: Player, number: Int) {
    waits.removeAll { $0 == player }
    teams[number].players.append(player)
  }

  func startPlayer(user: User) -> GameData {
    let play = Player.find(user)
    if curentPlayer == play {
      return GameData(data: ["какието", "ckjdf"], time: Int(secondRound), isPlayer: true)
    }
    return GameData(data: nil, time: Int(secondRound), isPlayer: false)
  }

  func nexPlayer() {
    currentTeam = (currentTeam + 1) % teams.count
    curentPlayer = teams[currentTeam].update()

  }

  func writeResult(user: User, results: [Bool]) {
    let play = Player.find(user)
    if curentPlayer == play {
      teams[currentTeam].point += results.filter { $0 }.count * pointK
      teams[currentTeam].point -= results.filter { !$0 }.count * pointK
      nexPlayer()
    }
  }

  func start() -> Bool {
  var val: Bool = true
    teams.forEach {
      if !$0.isValid {
        val = false
      }
    }
    if teams.count > 2, val {
      isStart = true
      return true
    } else {
      return false
    }
  }

  init(model: RoomResponse, user: User) {
    let user = Player.find(user)
    self.admin = user!
    teams = []
    waits = [admin]
    isOpen = model.isOpen
    name = model.name
    code = Int.random(in: 999...9999)
    id = Game.id
    Game.id += 1
  }
}
