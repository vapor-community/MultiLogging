//
//  DiscordLogger.swift
//  VaporLogging
//
//  Created by Jari Koopman on 22/06/2018.
//

import Foundation
import Vapor

public struct DiscordLoggerConfig: Service {
    /// URL to post to in PROD mode
    var prodURL: String
    /// URL to post to in DEV mode, defaults to `prodURL`
    var devURL: String
    /// Filters to use when getting a log message
    var filters: [LoggerFilter]
    /// Log messages using pretty rich embeds
    var useEmbeds: Bool
    /// If not using embeds, message format to use
    var messageFormat: String
    
    /// Creates a new DiscordLoggerConfig
    ///
    /// - parameters:
    ///     - prodURL: URL to post to in Production env
    ///     - devURL: URL to post to in Dev env, defaults to `prodURL`
    ///     - filters: Filters to use when getting a log message
    ///     - useEmbeds: Log messages using pretty rich embeds
    ///     - messageFormat:
    ///         Messages can contain the following variables:
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
    public init(prodURL: String, devURL: String = "", filters: [LoggerFilter] = [], useEmbeds: Bool, messageFormat: String = "") throws {
        guard prodURL.contains("discordapp.com/api/webhooks/"), devURL == "" ?  true : devURL.contains("discordapp.com/api/webhooks/") else {
            throw VaporError(identifier: "VaporLogging.invalidDiscordURL", reason: "Invalid discord webhook URL provided", suggestedFixes: ["Provide a valid discord webhook URL"])
        }
        guard messageFormat != "" || useEmbeds else {
            throw VaporError(identifier: "VaporLogging.noMessageFormat", reason: "No message format provided", suggestedFixes: ["Add a message format to your `DiscordLoggerConfig`"])
        }
        self.prodURL = prodURL
        self.devURL = devURL == "" ? prodURL : devURL
        self.filters = filters
        self.useEmbeds = useEmbeds
        self.messageFormat = messageFormat
    }
}

public class DiscordLogger: ServiceType, Logger {
    let config: DiscordLoggerConfig
    let client: Client
    let isRelease: Bool
    
    public required init(_ config: DiscordLoggerConfig, _ client: Client, _ isRelease: Bool) {
        self.config = config
        self.client = client
        self.isRelease = isRelease
    }
    
    public static var serviceSupports: [Any.Type] {
        return [Logger.self]
    }
    
    public static func makeService(for worker: Container) throws -> Self {
        return try .init(worker.make(), worker.make(), worker.environment.isRelease)
    }

    
    public struct DiscordPayload: Content {
        var embeds: [DiscordEmbed]?
        var content: String?
    }
    
    public struct DiscordEmbed: Content {
        struct Field: Content {
            var name: String
            var value: String
            var inline: Bool
        }
        
        struct Footer: Content {
            var text: String
        }
        
        var title: String
        var timestamp: String
        var description: String
        var color: Int
        var fields: [Field]
    }
    
    public func createPayload(_ message: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) throws -> DiscordPayload {
        if self.config.useEmbeds {
            let payload = DiscordPayload(embeds: [DiscordEmbed(title: "[ \(level.description) ]", timestamp: Date().iso8601, description: message, color: level.color, fields: [DiscordEmbed.Field(name: "File", value: "\(file.split(separator: "/").last!):\(line)", inline: false), DiscordEmbed.Field(name: "Function", value: function, inline: false)])], content: nil)
            return payload
        } else {
            guard self.config.messageFormat != "" else {
                throw VaporError(identifier: "VaporLogging.noMessageFormat", reason: "No message format provided", suggestedFixes: ["Add a message format to your `DiscordLoggerConfig`"])
            }
            var content = self.config.messageFormat
            content = content.replacingOccurrences(of: "{{message}}", with: message)
            content = content.replacingOccurrences(of: "{{level}}", with: level.description)
            content = content.replacingOccurrences(of: "{{file}}", with: file)
            content = content.replacingOccurrences(of: "{{function}}", with: function)
            content = content.replacingOccurrences(of: "{{line}}", with: "\(line)")
            content = content.replacingOccurrences(of: "{{column}}", with: "\(column)")
            return DiscordPayload(embeds: nil, content: content)
        }
    }
    
    /// See `Logger.log`
    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        var shouldFilter: Bool = false
        for filter in config.filters {
            if !filter(string, level, file, function, line, column) {
                shouldFilter = true
            }
        }
        guard !shouldFilter else { return }
        _ = self.client.post(self.isRelease ? config.prodURL : config.devURL, headers: HTTPHeaders(), beforeSend: { (req) in
            try req.content.encode(self.createPayload(string, at: level, file: file, function: function, line: line, column: column))
        })
    }
}
