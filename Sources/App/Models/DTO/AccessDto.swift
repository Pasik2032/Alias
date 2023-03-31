import JWT
import Vapor
import Fluent
import FluentSQLiteDriver

struct AccessDto: Content {
    let accessToken: String
    let expiredAt: Date
}
