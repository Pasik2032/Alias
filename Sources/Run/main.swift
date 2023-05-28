import App
import Vapor
import JWT

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
app.http.server.configuration.hostname = "172.20.10.3"
app.http.server.configuration.port = 8111
app.webSocket("socket") { req, ws in
  // Connected WebSocket.
  print(ws)
  SocketUser.newScoket(ws: ws, db: req.db)
}
defer { app.shutdown() }
app.jwt.signers.use(.hs256(key: "RomaSuper"))
try configure(app)
try app.run()
