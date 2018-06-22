import Vapor

public enum LoggerType {
    case file, discord, slack, console
}

/// Takes all arguments to a log call and returns a bool indicating wether or not to filter the message
public typealias LoggerFilter = ((String, LogLevel, String, String, UInt, UInt) -> Bool)

public struct VaporLoggingConfig: Service {
    var types: [LoggerType]
}

public class VaporLogger: ServiceType, Logger {
    init(_ loggers: [Logger]) {
        self.loggers = loggers
    }
    
    private var loggers: [Logger]
    
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        self.loggers.forEach { $0.log(string, at: level, file: file, function: function, line: line, column: column) }
    }
    
    public static func makeService(for worker: Container) throws -> Self {
        var config = try worker.make(VaporLoggingConfig.self)
        // TODO: IMPLEMENT
        let logger = try worker.make(ConsoleLogger.self)
        return .init([logger])
    }
}
