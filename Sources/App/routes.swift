import Fluent
import Vapor
import JWT

func routes(_ app: Application) throws {


  let room = app.grouped("room")

  room.put(":id", "setting") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    let data = try req.content.decode(Setting.self)
    if game.admin != Player(user: user) {
      throw Abort(.badRequest)
    }

    game.updateSetting(model: data)
    return game.dto
  }

  room.post(":id", "room", "replace") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    let data = try req.content.decode(NewAdmin.self)
    if game.admin != Player(user: user) {
      throw Abort(.badRequest)
    }
    game.newAdmin(name: data.name)
    return game.dto
  }

  room.post(":id", "game") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    let data = try req.content.decode(ResultGame.self)
    game.writeResult(user: user, results: data.result)
    return game.dto
  }

  room.get(":id", "game") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    return game.startPlayer(user: user)
  }

  room.get(":id", "start") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    if game.admin != Player(user: user) {
      throw Abort(.badRequest)
    }
    guard game.start() else {
      throw Abort(.badRequest)
    }
    return game.dto
  }

  room.get(":id") { req in
    let id = Int(req.parameters.get("id")!)!
    return Game.find(id: id).dto
  }

  room.delete(":id") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    if game.admin != Player(user: user) {
      throw Abort(.badRequest)
    }
    Game.delete(model: game)
    return "ok"
  }

  room.post(":id", "team", ":idTeam", "join") { req in
    let id = Int(req.parameters.get("id")!)!
    let idTeam = Int(req.parameters.get("idTeam")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    game.selectTeam(player: Player.find(user)!, number: idTeam)
    return game.dto
  }


  room.post(":id", "team") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)
    let game = Game.find(id: id)
    if game.admin != Player(user: user) {
      throw Abort(.badRequest)
    }
    game.createTeam()
    return game.dto
  }

  room.post("join", ":id") { req in
    let id = Int(req.parameters.get("id")!)!
    let user = try req.jwt.verify(as: User.self)

    let game = Game.find(id: id)
    if let player = Player.find(user) {
      game.join(player: player)
    }
    return game.dto
  }


  room.get("list") { req in
    let rooms = Game.games
      .filter { $0.isVisibel }
      .map { $0.dto }

    return rooms
  }

  room.post("create") { req in
    let data = try req.content.decode(RoomResponse.self)
    let user = try req.jwt.verify(as: User.self)

    let game = Game(model: data, user: user)
    Game.games.append(game)

    return game.dto
  }



  app.get("me") { req -> HTTPStatus in
    let payload = try req.jwt.verify(as: User.self)
    print(payload)
    return .ok
  }

  app.post("login") { req in
    let model = try req.content.decode(LoginReqest.self)
    let user = Player.players.first {
      $0.login == model.login && $0.password == model.password
    }

    let userModel = User.users.first {
      $0.login == model.login && $0.password == model.password
    }

    if let userModel {
      return try [
        "token": req.jwt.sign(userModel)
      ]
    } else {
      return  [
        "message": "not found"
      ]
    }
  }



  app.post("reg") { req in
    let registerUser = try req.content.decode(RegisterReqest.self)
      let newUser = User(
        name: registerUser.name,
        password: registerUser.password,
        login: registerUser.login,
        expiration: ExpirationClaim(value: Date(timeIntervalSince1970: 1712418626.0))
      )

    User.users.append(newUser)
    Player.players.append(Player(user: newUser))
    return try [
      "token": req.jwt.sign(newUser)
    ]
  }
}


struct LoginReqest: Content {
  var login: String
  var password: String
}

struct RegisterReqest: Content {
  var login: String
  var password: String
  var name: String
}

struct Room: Content {
  static var rooms: [Room] = []
  static var id = 0
  let name: String
  let id: Int
  let isOpen: Bool
  let code: Int?
  let admin: UserModel
  var teams: [Team]
  var wait: [UserModel]
  var start: Bool
  var setting: Setting
}

struct RoomResponse: Content {
  let name: String
  let isOpen: Bool
}

struct RoomCode: Content {
  let code: Int
}

struct ResultGame: Content {
  let result: [Bool]
}

struct GameData: Content {
  let data: [String]?
  let time: Int
  let isPlayer: Bool
}

struct Team: Content {
  static var id: Int = 0
  let id: Int
  var players: [UserModel]
  let points: Int
}

struct NewAdmin: Content {
  let name: String
}

struct Setting: Content {
  let timeRound: Int
  let poin: Int
}
