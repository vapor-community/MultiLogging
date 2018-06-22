# VaporLogging
[![Vapor 3](https://img.shields.io/badge/vapor-3.0-blue.svg?style=flat)](https://vapor.codes)
[![Swift 4.1](https://img.shields.io/badge/swift-4.2-orange.svg?style=flat)](http://swift.org)

##

VaporLogging is a Vapor 3 utility package for logging. It allows you to log to files, Discord and Slack next to the default console logger. Next to that it allows you to run multiple loggers at once, so you can log to, for example, both Console and Discord

## Installation
Vapor Logging can be installed using SPM
```swift
.package(url: "https://github.com/MrLotU/VaporLogging.git", from: "0.0.1")
```

## Usage
Setting up Vapor Logging is easy to do and requires only little code.

### Registering a logger
In your `Configure.swift` file, add the following for each logger you want to use:
```swift
services.register(LoggerNameConfig(<params>))
services.register(LoggerName.self)
```
So for the Discord logger that'd be something like this:
```swift
services.register(DiscordLoggerConfig(prodURL: "webhookURL", useEmbeds: true))
services.register(DiscordLogger.self)
```

### Setting which loggers to use
If you only want to use one logger, prefer that logger in your config like so:
```swift
config.prefer(DiscordLogger.self, for: Logger.self)
```
If you however want to use multiple, say the discord logger and the default console logger, add the following:
```swift
services.register(VaporLoggingConfig(types: [.discord, .console])) // Order does not matter
services.register(VaporLogger.self)
config.prefer(VaporLogger.self, for: Logger.self)
```

### Advanced

COMMING SOON