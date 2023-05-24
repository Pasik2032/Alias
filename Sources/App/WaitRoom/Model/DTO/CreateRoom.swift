//
//  File.swift
//  
//
//  Created by Даниил Пасилецкий on 22.05.2023.
//

import Foundation
import Vapor

struct CreateRoomDTO: Content {
  var name: String
  var isPrivate: Bool
}
