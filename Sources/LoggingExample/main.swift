import MultiLogging
import Vapor

/// Creates an instance of Application. This is called from main.swift in the run target.
public func app(_ env: Environment) throws -> Application {
    var config = Config.default()
    var env = env
    var services = Services.default()
    try configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    try boot(app)
    return app
}

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    try app.make(Logger.self).info("Startup success")
    try app.make(Logger.self).info("Filtered success")
}

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    try services.register(DiscordLoggerConfig(prodURL: "DiscordTokenGoesHere", useEmbeds: true))
    services.register(DiscordLogger.self)
    
    services.register(VaporLoggingConfig(types: [.discord, .console]))
    services.register(VaporLogger.self)
    config.prefer(VaporLogger.self, for: Logger.self)
}

public func routes(_ router: Router) throws {
    router.get("hello") { req in
        return "Hello, World"
    }
}

try app(.detect()).run()
