import Vapor

public enum LoggerType {
    case file, discord, slack, console
}

/// Takes all arguments to a log call and returns a bool indicating wether or not to filter the message
public typealias LoggerFilter = ((String, LogLevel, String, String, UInt, UInt) -> Bool)

public struct MultiLoggerConfig: Service {
    var types: [LoggerType]
    
    public init(types: [LoggerType]) {
        self.types = types
    }
}

public class MultiLogger: ServiceType, Logger {
    required init(_ loggers: [Logger]) {
        self.loggers = loggers
    }
    
    private var loggers: [Logger]
    
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        self.loggers.forEach { $0.log(string, at: level, file: file, function: function, line: line, column: column) }
    }
    
    public static var serviceSupports: [Any.Type] {
        return [Logger.self]
    }

    public static func makeService(for worker: Container) throws -> Self {
        let config = try worker.make(MultiLoggerConfig.self)
        var loggers: [Logger] = []
        for type in config.types {
            switch type {
            case .file: try loggers.append(worker.make(FileLogger.self))
            case .discord: try loggers.append(worker.make(DiscordLogger.self))
            case .slack: try loggers.append(worker.make(SlackLogger.self))
            case .console: try loggers.append(worker.make(ConsoleLogger.self))
            }
        }
        return .init(loggers)
    }
}
