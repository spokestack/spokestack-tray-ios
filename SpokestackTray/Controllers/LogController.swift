//
//  LogController.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 9/3/20.
//

import Foundation
import OSLog

public class LogController {
    
    // MARK: Public (properties)
    
    public static let shared: LogController = LogController()
    
    // MARK: Private (properties)
    
    #if canImport(OSLog)
    private lazy var logger: OSLog = {
        
        let bundleID: String = Bundle(for: LogController.self).bundleIdentifier ?? "spokestack-ios-tray"
        return OSLog(subsystem: bundleID, category: "Pipeline")
    }()
    #else
    private lazy var logger = {
        return self
    }()
    #endif
    
    // MARK: Initializers
    
    private init() {}
    
    // MARK: Public (methods)
    
    #if canImport(OSLog)
    public func log(_ message: String, level: OSLogType = .debug) -> Void {
        os_log("%@", log: self.logger, type: level, message)
    }
    #else
    
    public enum LogLevel {
        case info
        case error
    }
    
    public func log(_ message: String, level: LogLevel = .info) -> Void {
        print(message)
    }
    #endif
}
