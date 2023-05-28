//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 25.05.2023.
//

import Foundation
import WebSocketKit
import Vapor
import FluentKit

public final class SocketUser {
  var ws: WebSocket

  init(ws: WebSocket) {
    self.ws = ws
  }

  public static func newScoket(ws: WebSocket, db: Database) {
    let su = SocketUser(ws: ws)
    su.ws.onText { ws, str in
      print(str)
      guard let model = try? JSONDecoder().decode(SocketUserType.self, from: Data(str.utf8)) else { return }
      switch model.type {
      case .allRoom:
        wsAllRooms.append(su)
      case .waitRoom:
        let room = try? await WaitRoom.find(model.id, on: db)
        if let uud = try? room?.requireID() {
          if wsRoomsSub[uud] == nil {
            wsRoomsSub[uud] = [su]
          } else {
            wsRoomsSub[uud]?.append(su)
          }
        }
        room?.socketFolow.append(su)
      }
    }
    wsUsersWaitSend.append(su)
  }

  static var wsUsersWaitSend: [SocketUser] = []
  static var wsAllRooms: [SocketUser] = []


  static var wsRoomsSub: [UUID:[SocketUser]] = [:]
}

struct SocketUserType: Content {
  var type: SocketUserTypeSup
  var id: UUID?
}

enum SocketUserTypeSup: String, Content {
  case allRoom
  case waitRoom
}
