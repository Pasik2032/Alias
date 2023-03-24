import Vapor

struct AccessDto: Content {
    let accessToken: String
    let expiredAt: Date
}
