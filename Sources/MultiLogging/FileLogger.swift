//
//  FileLogger.swift
//  VaporLogging
//
//  Created by Jari Koopman on 22/06/2018.
//

import Foundation
import Vapor

public struct FileLoggerConfig: Service {
    /// File to post to in PROD mode
    var prodFile: String
    /// File to post to in DEV mode
    var devFile: String
    /// Filters to use when getting a log message
    var filters: [LoggerFilter]
    /// Format to post logs in
    var format: String
    
    /// Creates a new FileLoggerConfig
    ///
    /// - parameters:
    ///     - prodFile: File to post to in Production env
    ///     - devFile: File to post to in Dev env, defaults to `prodFile`
    ///     - filters: Filters to use when getting a log message
    ///     - format:
    ///         Format can contain the following variables:
    ///
    ///         {{message}} - REQUIRED - The logged message
    ///
    ///         {{level}} - The log level, ie INFO, DEBUG
    ///
    ///         {{file}} - The file from where the log was triggered
    ///
    ///         {{function}} - The function that triggered the log
    ///
    ///         {{line}} - The line on which the log was triggered
    ///
    ///         {{column}} - The column the log was triggered on
    public init(prodFile: String, devFile: String = "", filters: [LoggerFilter] = [], format: String) {
        self.prodFile = prodFile
        self.devFile = devFile == "" ? prodFile : devFile
        self.filters = filters
        self.format = format
    }
}

public class FileLogger: ServiceType, Logger {
    let config: FileLoggerConfig
    let isRelease: Bool
    
    public required init(_ config: FileLoggerConfig, _ isRelease: Bool) {
        self.config = config
        self.isRelease = isRelease
    }
    
    public static var serviceSupports: [Any.Type] {
        return [Logger.self]
    }
    
    public static func makeService(for worker: Container) throws -> Self {
        return try .init(worker.make(), worker.environment.isRelease)
    }
    
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        var shouldFilter: Bool = false
        for filter in config.filters {
            if !filter(string, level, file, function, line, column) {
                shouldFilter = true
            }
        }
        guard !shouldFilter else { return }
        guard let log = URL(string: isRelease ? config.prodFile : config.prodFile) else { return }
        let string = string + "\n"
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
}
