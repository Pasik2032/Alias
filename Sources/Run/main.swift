import App
import Vapor
import Fluent
//import FluentSQLite
import JWT
import FluentSQLiteDriver

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
