import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  app.databases.use(.postgres(
    hostname: "localhost",
    port: 5431,
    username: "vapor_username",
    password: "vapor_password",
    database: "vapor_database"
  ), as: .psql)

  app.migrations.add(CreateTodo())
  app.migrations.add(CreateUsers())
  app.migrations.add(CreateTokens())
  app.migrations.add(CreateWaitRoom())
  app.migrations.add(CreateTeam())
  app.migrations.add(CreatePlayer())

  try app.autoMigrate().wait()

  // register routes
  try routes(app)
}
