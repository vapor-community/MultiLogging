import Vapor

public enum LoggerType {
    case File, Discord, Slack, Default
}

public struct VaporLoggingConfig: Service {
    var type: LoggerType
}

public class VaporLogger: ServiceType, Logger {
    init(_ logger: Logger) {
        self.logger = logger
    }
    
    private var logger: Logger
    
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        self.logger.log(string, at: level, file: file, function: function, line: line, column: column)
    }
    
    public static func makeService(for worker: Container) throws -> Self {
        var config = try worker.make(VaporLoggingConfig.self)
        // TODO: IMPLEMENT
        let logger = try worker.make(Logger.self)
        return .init(logger)
    }
}
