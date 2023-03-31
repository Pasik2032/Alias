import JWT
import Vapor
import Fluent

struct AccessDto: Content {
    let accessToken: String
    let expiredAt: Date
}
