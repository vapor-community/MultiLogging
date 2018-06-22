//
//  Utils.swift
//  VaporLogging
//
//  Created by Jari Koopman on 22/06/2018.
//

import Foundation
import Vapor

extension LogLevel {
    var color: Int {
        switch self {
        case .info:
            return 0x77dd77
        case .error, .fatal:
            return 0xff6961
        case .warning:
            return 0xffb347
        default:
            return 7506394
        }
    }
    var hexColor: String {
        switch self {
        case .info:
            return "77dd77"
        case .error, .fatal:
            return "ff6961"
        case .warning:
            return "ffb347"
        default:
            return ""
        }
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    public var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
