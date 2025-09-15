//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Logging
public import MunirServiceKit

// NOTE: There are two separate classes with the name Logger
//       being used in this file.
public extension DebugLogger {
    static func configureSwiftLogging() {
        LoggingSystem.bootstrap { _ in
            CLForwardingLogHandler()
        }
    }

    // A LogHandler that forwards to CocoaLumberjack.
    private struct CLForwardingLogHandler: LogHandler {
        public init() {}

        @inlinable
        public func log(
            level: Logging.Logger.Level,
            message: Logging.Logger.Message,
            metadata: Logging.Logger.Metadata?,
            source: String,
            file: String,
            function: String,
            line: UInt
        ) {
            // TODO: Remove.
            let message = "MCSDK: " + message.description
            let line = Int(line)

            switch level {
            case .trace:
                MunirServiceKit.Logger.verbose(message, file: file, function: function, line: line)
            case .debug:
                MunirServiceKit.Logger.debug(message, file: file, function: function, line: line)
            case .info,
                 .notice:
                MunirServiceKit.Logger.info(message, file: file, function: function, line: line)
            case .warning:
                MunirServiceKit.Logger.warn(message, file: file, function: function, line: line)
            case .error,
                 .critical:
                MunirServiceKit.Logger.error(message, file: file, function: function, line: line)
            }
        }

        @inlinable
        public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
            get {
                return self.metadata[metadataKey]
            }
            set {
                self.metadata[metadataKey] = newValue
            }
        }

        @inlinable public var metadata: Logging.Logger.Metadata {
            get {
                return [:]
            }
            set {
                _ = newValue
            }
        }

        @inlinable public var logLevel: Logging.Logger.Level {
            get {
                #if DEBUG
                return .trace
                #else
                return .info
                #endif
            }
            set {
                _ = newValue
            }
        }
    }
}
