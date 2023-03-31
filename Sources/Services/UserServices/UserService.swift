//
//  UserService.swift
//  App
//
//  Created by Timur Shafigullin on 25/01/2019.
//
import Vapor
import Fluent
//import FluentSQLite
import JWT
import FluentSQLiteDriver

protocol UserService {
    
    func signUp(request: Request, user: User) throws -> EventLoopFuture<ResponseDto>
}
