import App
import Vapor
import JWT

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
app.jwt.signers.use(.hs256(key: "RomaSuper"))
try configure(app)
try app.run()
